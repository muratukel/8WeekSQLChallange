## ABOUT DATASET 

![img](https://8weeksqlchallenge.com/images/case-study-designs/6.png)

# Clique Bait Online Seafood Store Case Study

Clique Bait is not your ordinary online seafood store. The founder and CEO, Danny, was part of a digital data analytics team and he wanted to combine his expertise with the seafood industry. In this case study, we'll help Danny achieve his vision by analyzing his dataset and devising creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Available Datasets

To solve the questions in this case study, you'll need to work with a total of 5 datasets. Here's an overview of the data:

### Users

Customers visiting the Clique Bait website are tagged using their `cookie_id`.

| user_id | cookie_id | start_date          |
|---------|-----------|---------------------|
| 397     | 3759ff    | 2020-03-30 00:00:00 |
| 215     | 863329    | 2020-01-26 00:00:00 |
| ...     | ...       | ...                 |

### Events

Customer visits are recorded in the events table at the `cookie_id` level. The `event_type` and `page_id` values can be used to connect with other tables and obtain more information about each event.

| visit_id | cookie_id | page_id | event_type | sequence_number | event_time          |
|----------|-----------|---------|------------|-----------------|---------------------|
| 719fd3   | 3d83d3    | 5       | 1          | 4               | 2020-03-02 00:29:09 |
| fb1eb1   | c5ff25    | 5       | 2          | 8               | 2020-01-22 07:59:16 |
| ...      | ...       | ...     | ...        | ...             | ...                 |

### Event Identifier

This table describes the types of events captured by Clique Bait's data systems.

| event_type | event_name      |
|------------|-----------------|
| 1          | Page View       |
| 2          | Add to Cart     |
| ...        | ...             |

### Campaign Identifier

This table provides information about the campaigns run on the website in 2020.

| campaign_id | products | campaign_name               | start_date          | end_date            |
|-------------|----------|-----------------------------|---------------------|---------------------|
| 1           | 1-3      | BOGOF - Fishing For Compliments | 2020-01-01 00:00:00 | 2020-01-14 00:00:00 |
| ...         | ...      | ...                         | ...                 | ...                 |

### Page Hierarchy

This table lists pages on the Clique Bait website and their attributes.

| page_id | page_name     | product_category | product_id |
|---------|---------------|------------------|------------|
| 1       | Home Page     | null             | null       |
| ...     | ...           | ...              | ...        |

## Interactive SQL Instance

You can use the provided [DB Fiddle instance](link_to_fiddle) to easily access and analyze the example datasets. This interactive session provides all you need to start writing SQL queries to solve the case study questions.

Feel free to choose any SQL dialect you prefer. The existing Fiddle uses PostgreSQL 13 as default.

For detailed schema SQL and example solutions, serious SQL students can use their Docker setup within the course player.

[link_to_fiddle]: link_here
