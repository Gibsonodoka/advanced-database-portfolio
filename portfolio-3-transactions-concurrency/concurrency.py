import threading, time
import psycopg2

DSN = "host=/tmp/pgs port=5453 user=postgres dbname=church_db"


def connect(isolation="READ COMMITTED"):
    c = psycopg2.connect(DSN)
    c.cursor().execute(f"SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL {isolation}")
    c.commit()
    return c


def query(c, sql, args=None):
    cur = c.cursor()
    cur.execute(sql, args)
    return cur.fetchone()[0] if cur.description else None


def reset():
    c = connect()
    query(c, "UPDATE cms.fund SET balance = 1000 WHERE fund_id IN (1, 2)")
    c.commit()
    c.close()


def balance(fund_id):
    c = connect()
    value = query(c, "SELECT balance FROM cms.fund WHERE fund_id = %s", (fund_id,))
    c.close()
    return value


def lost_update(mode):
    reset()
    both_read = threading.Barrier(2)

    def worker(name, amount):
        c = connect()
        if mode == "atomic":
            both_read.wait()
            query(c, "UPDATE cms.fund SET balance = balance + %s WHERE fund_id = 1", (amount,))
        else:
            lock = " FOR UPDATE" if mode == "for_update" else ""
            if mode == "for_update" and name == "B":
                time.sleep(0.2)
            value = query(c, "SELECT balance FROM cms.fund WHERE fund_id = 1" + lock)
            print(f"  {name} read balance {value}")
            if mode != "for_update":
                both_read.wait()
            query(c, "UPDATE cms.fund SET balance = %s WHERE fund_id = 1", (value + amount,))
        c.commit()
        print(f"  {name} added {amount} and committed")

    threads = [threading.Thread(target=worker, args=("A", 100)),
               threading.Thread(target=worker, args=("B", 200))]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    final = balance(1)
    print(f"  final balance {final} (expected 1300) -> {'CORRECT' if final == 1300 else 'LOST UPDATE'}")


def deadlock(ordered):
    reset()

    def transfer(name, source, target):
        c = connect()
        first, second = sorted([source, target]) if ordered else (source, target)
        try:
            query(c, "UPDATE cms.fund SET balance = balance WHERE fund_id = %s", (first,))
            time.sleep(1)
            query(c, "UPDATE cms.fund SET balance = balance WHERE fund_id = %s", (second,))
            query(c, "UPDATE cms.fund SET balance = balance - 50 WHERE fund_id = %s", (source,))
            query(c, "UPDATE cms.fund SET balance = balance + 50 WHERE fund_id = %s", (target,))
            c.commit()
            print(f"  {name} transfer {source}->{target} committed")
        except psycopg2.errors.DeadlockDetected:
            c.rollback()
            print(f"  {name} transfer {source}->{target} ERROR: deadlock detected, rolled back")

    threads = [threading.Thread(target=transfer, args=("A", 1, 2)),
               threading.Thread(target=transfer, args=("B", 2, 1))]
    for t in threads:
        t.start()
    for t in threads:
        t.join()


def non_repeatable_read(isolation):
    reset()
    first_read = threading.Event()
    updated = threading.Event()
    reads = []

    def reader():
        c = connect(isolation)
        reads.append(query(c, "SELECT balance FROM cms.fund WHERE fund_id = 1"))
        first_read.set()
        updated.wait()
        reads.append(query(c, "SELECT balance FROM cms.fund WHERE fund_id = 1"))
        c.commit()

    def writer():
        first_read.wait()
        c = connect()
        query(c, "UPDATE cms.fund SET balance = balance + 500 WHERE fund_id = 1")
        c.commit()
        updated.set()

    threads = [threading.Thread(target=reader), threading.Thread(target=writer)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    print(f"  first read {reads[0]}, second read {reads[1]} -> {'DIFFERENT' if reads[0] != reads[1] else 'SAME'}")


print("1. Lost update (read then write)")
lost_update("naive")
print("2. Fix: atomic UPDATE balance = balance + x")
lost_update("atomic")
print("3. Fix: SELECT ... FOR UPDATE")
lost_update("for_update")
print("4. Non-repeatable read at READ COMMITTED")
non_repeatable_read("READ COMMITTED")
print("5. Same test at REPEATABLE READ")
non_repeatable_read("REPEATABLE READ")
print("6. Deadlock: locks taken in opposite order")
deadlock(ordered=False)
print("7. Fix: always lock the lower fund_id first")
deadlock(ordered=True)
