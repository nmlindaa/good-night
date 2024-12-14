# README

## Good Night API

## Description

This project provides APIs for users to log their sleep time and view the sleep records of their followed users.

## Prerequisites

Before you begin, ensure you have met the following requirements:

* Ruby version: 3.3.6
* Rails version: 8.0.0
* PostgreSQL: 14.0
* Redis: 7.2.6

## Setup and Configuration

To set up the project locally, follow these steps:

1. Clone the repository:
   ```
   git clone https://github.com/nmlindaa/good-night.git
   ```

2. Navigate to the project directory:
   ```
   cd good-night
   ```

3. Install the required gems:
   ```
   bundle install
   ```

4. Ensure PostgreSQL is running on your local machine:
   ```
   # On macOS with Homebrew:
   brew services start postgresql
   
   # On Ubuntu:
   sudo service postgresql start
   ```

5. Ensure Redis is running on your local machine:
   ```
   # On macOS with Homebrew:
   brew services start redis
   
   # On Ubuntu:
   sudo service redis-server start
   ```

6. Create the database:
   ```
   rails db:create
   ```

7. Run database migrations:
   ```
   rails db:migrate
   ```

8. Seed the database:
   ```
   rails db:seed
   ```

9. Start Sidekiq (for background job processing):
   ```
   bundle exec sidekiq
   ```

10. In a new terminal window, start the Rails server:
   ```
   rails s
   ```

Your application should now be running at `http://localhost:3000`.

## Running Tests

To run the test suite:

```
rspec
```

### Endpoints

#### Sleep Records

##### Clock In Operation

**POST** `/api/v1/users/:user_id/sleep_records/clock_in`
- Create a new sleep record for user.
- Parameters:
  - `user_id`: The ID of the user (uuid)
- Response:
  ```json
  {
    "message": "Successfully clocked in",
    "sleep_record": {
        "id": "ec82a177-adfb-45e4-a7ab-71fcab4d1136",
        "user_id": "cbc2189f-a9ca-4520-9d19-43c5b5a58e70",
        "bed_time": "2024-12-14T09:24:53.326Z",
        "wake_time": null,
        "duration_minutes": null,
        "created_at": "2024-12-14T09:24:53.330Z",
        "updated_at": "2024-12-14T09:24:53.330Z"
    }
  }
  ```

**PATCH** `/api/v1/users/:user_id/sleep_records/clock_out`
- Complete sleep record for user.
- Parameters:
  - `user_id`: The ID of the user (uuid)
- Response:
  ```json
  {
    "message": "Successfully clocked out",
    "sleep_record": {
        "id": "ec82a177-adfb-45e4-a7ab-71fcab4d1136",
        "user_id": "cbc2189f-a9ca-4520-9d19-43c5b5a58e70",
        "bed_time": "2024-12-14T09:24:53.326Z",
        "wake_time": "2024-12-14T09:34:53.326Z",
        "duration_minutes": 60,
        "created_at": "2024-12-14T09:24:53.330Z",
        "updated_at": "2024-12-14T09:34:53.330Z"
    }
  }
  ```

##### Get Sleep Records

**GET** `/api/v1/users/:user_id/sleep_records`
- Returns all clocked-in times for the current user, ordered by created_at
- Query Parameters:
  - `user_id`: The ID of the user (uuid)
  - `page`: Page number for pagination (integer, optional)
  - `per_page`: Number of records per page (integer, optional, default: 10)
- Response:
  ```json
  {
    "sleep_records": [
      {
        "id":"ec82a177-adfb-45e4-a7ab-71fcab4d1136",
        "user_id":"cbc2189f-a9ca-4520-9d19-43c5b5a58e70",
        "bed_time":"2024-12-14T09:24:53.326Z",
        "wake_time":"2024-12-14T09:25:09.460Z",
        "duration_minutes":0,
        "created_at":"2024-12-14T09:24:53.330Z",
        "updated_at":"2024-12-14T09:25:09.460Z"
      }
    ],
    "page":1,
    "total_pages":1
  }
  ```

#### Following

##### Follow User

**POST** `/api/v1/follows`
- Follows another user.
- Request Body:
  ```json
  {
    "follow": {
        "followed_id": "cbc2189f-a9ca-4520-9d19-43c5b5a58e70",
        "follower_id": "82905c60-a2fd-49fd-bbb6-b3eb988718e7"
    }
  }
  ```
- Response:
  ```json
  {
    "message": "Successfully followed user",
  }
  ```

##### Unfollow User

**PATCH** `/api/v1/follows`
- Unfollows a user.
- Request Body:
  ```json
  {
    "follow": {
        "followed_id": "cbc2189f-a9ca-4520-9d19-43c5b5a58e70",
        "follower_id": "82905c60-a2fd-49fd-bbb6-b3eb988718e7"
    }
  }
  ```
- Response:
  ```json
  {
    "message": "Successfully unfollowed user",
  }
  ```

#### Following Sleep Record

##### V1 (Table)

**GET** `/api/v1/users/:user_id/following_sleep_records`
- Returns all followings sleep record from the previous week
- Query Parameters:
  - `user_id`: The ID of the user (uuid)
  - `page`: Page number for pagination (integer, optional)
  - `per_page`: Number of records per page (integer, optional, default: 10)
- Response:
  ```json
  {
    "sleep_records": [
      {
        "id":"ec82a177-adfb-45e4-a7ab-71fcab4d1136",
        "user_id":"cbc2189f-a9ca-4520-9d19-43c5b5a58e70",
        "bed_time":"2024-12-14T09:24:53.326Z",
        "wake_time":"2024-12-14T09:25:09.460Z",
        "duration_minutes":0,
        "created_at":"2024-12-14T09:24:53.330Z",
        "updated_at":"2024-12-14T09:25:09.460Z"
      },
      ...
    ],
    "page":1,
    "total_pages":1
  }
  ```

##### V2 (Materialized View)

**GET** `/api/v2/users/:user_id/following_sleep_records`
- Returns all followings sleep record from the previous week
- Query Parameters:
  - `user_id`: The ID of the user (uuid)
  - `page`: Page number for pagination (integer, optional)
  - `per_page`: Number of records per page (integer, optional, default: 10)
- Response:
  ```json
  {
    "sleep_records": [
      {
        "id":"ec82a177-adfb-45e4-a7ab-71fcab4d1136",
        "user_id":"cbc2189f-a9ca-4520-9d19-43c5b5a58e70",
        "bed_time":"2024-12-14T09:24:53.326Z",
        "wake_time":"2024-12-14T09:25:09.460Z",
        "duration_minutes":0,
        "created_at":"2024-12-14T09:24:53.330Z",
        "updated_at":"2024-12-14T09:25:09.460Z"
      },
      ...
    ],
    "page":1,
    "total_pages":1
  }
  ```
