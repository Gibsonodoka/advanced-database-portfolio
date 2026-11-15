# Technical Reflection


## Design Choices

One key design choice was storing each fund's balance in the fund table and updating it in the same transaction as the donation. This makes balance checks fast, and the transaction tests showed that a failed step never leaves the balance and the donations out of step.

## Challenges Faced

My main challenge was the NoSQL portfolio. I first planned to use MongoDB, but setting it up was a bit overwhelming, so I used PostgreSQL JSONB for the document model and Redis for the key-value model. This showed me that the data model matters more than the specific product.

## Lessons Learned

The optimisation work taught me that indexes help most when a query returns a few rows, such as one member's attendance or donations, which became over 100 times faster. Queries that add up many rows, like the top donors report, improved much less. The concurrency tests also showed me how easily a lost update happens when two users change the same balance, and why atomic updates or row locks are needed.

## Future Improvements

With more time, I would add a materialised view for the donation reports, use synchronous replication for donations so no payment is lost during failover, and deploy the database to a cloud service.