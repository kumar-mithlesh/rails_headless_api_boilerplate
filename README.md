# Rails Boilerplate 🚀
This repository provides a boilerplate for kickstarting a new Headless Rails project. It includes essential configurations for authentication, authorization, and a simple API structure. Clone the repository and start building your API seamlessly.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Installation

Follow these steps to install and set up the project:

1. Clone the repository:
   ```bash
   git clone https://github.com/kumar-mithlesh/rails_boilerplate.git
   ```

2. (Optional) Rename the project directory to your desired name:
   ```bash
   mv rails_boilerplate your_project_name
   ```

3. Navigate to the project directory:
   ```bash
   cd your_project_name
   ```

4. Run the setup script:
   ```bash
   bin/setup
   ```

## Usage

Generate a new API in 5 simple steps:

1. **Generate a model**:
   ```bash
   rails g model ModelName
   ```

2. **Generate a controller** and inherit it from the resource controller and define the name of the model in the model class all the CRUD methods will be available by default.
    [See example](app/controllers/api/users_controller.rb)
   ```bash
   rails g controller ControllerName
   ```
   ```ruby
    class ControllerNameController < ResourceController
    end
   ```


3. **Add routes** to `config/routes.rb`:
   ```ruby
   resources :model_names
   ```

4. **Create a serializer** and inherit it from `BaseSerializer`:
   ```ruby
   class ModelNameSerializer < BaseSerializer
   end
   ```

5. **Create a policy** for the model:
   ```ruby
   class ModelNamePolicy < ApplicationPolicy
   end
   ```

## Features

The generated API will have the following features:

1. **Filtering**:
   Use query parameters to filter results. Example:
   ```http
   GET http://localhost:3000/api/users?filter[username_eq]=example
   ```
   For more details on filtering options, check out the [Ransack matchers documentation](https://activerecord-hackery.github.io/ransack/getting-started/search-matches/).


2. **Sorting**:
   Sort results by any attribute. Use `sort` with `-` for descending order. Example:
   ```http
   GET http://localhost:3000/api/users?sort=-id
   ```

3. **Pagination**:
   Control the number of results per page using `per_page`. Example:
   ```http
   GET http://localhost:3000/api/users?per_page=6
   ```

4. **Includes**:
   Fetch related data using `include`. Example:
   ```http
   GET http://localhost:3000/api/users/5?include=roles
   ```

## Signup Example

Here is an example cURL request for user signup:

```bash
curl --location 'http://localhost:3000/api/authentication/signup' \
--header 'Content-Type: application/json' \
--data-raw '{
    "user":{
        "username": "example",
        "email": "example@example.com",
        "password": "example@123",
        "password_confirmation": "example@123"
    }
}'
```

## Authentication Example

Here is an example cURL request for user authentication:
The meta.token returned in the response can be used as a Bearer token for authorization in other API requests. Here's an example of how to use it in the Authorization header for a subsequent API call:

```bash
curl --location 'http://localhost:3000/api/authentication/login' \
--header 'Content-Type: application/json' \
--data-raw '{
    "user":{
        "username_or_email": "example@gmail.com",
        "password": "example@123"
    }
}'
```

## Third-Party Gems

This boilerplate utilizes a variety of well-maintained third-party gems to provide essential features. Below is a breakdown of their purposes and references:

### API Functionality

- **[jsonapi-serializer (~> 2.2)](https://github.com/jsonapi-serializer/jsonapi-serializer)**: Facilitates efficient and standardized JSON:API serialization for API responses.
- **[ransack (>= 4.1)](https://github.com/activerecord-hackery/ransack)**: Offers powerful filtering capabilities through the Ransack framework.

- **[chusaku](https://github.com/nshki/chusaku)**: Automatically generates inline documentation for your Rails routes.

### Authentication and Authorization

- **[bcrypt (~> 3.1)](https://github.com/codahale/bcrypt-ruby)**: Implements secure password hashing using industry-standard bcrypt algorithms.
- **[jwt (~> 2.2)](https://github.com/jwt/ruby-jwt)**: Generates JSON Web Tokens (JWTs) for user authentication and authorization.
- **[pundit (~> 2.4)](https://github.com/varvet/pundit)**: Provides fine-grained access control with Pundit policies.

### Pagination

- **[pagy (~> 9.1)](https://github.com/ddnexus/pagy)**: A highly efficient and flexible pagination library for managing large datasets.

### Error Handling

- **[stackprof (development dependency)](https://github.com/tmm1/stackprof)**: Delivers comprehensive profiling to identify performance bottlenecks.
- **[sentry-ruby (optional)](https://github.com/getsentry/sentry-ruby)**: Enables error tracking and reporting with Sentry.
- **[sentry-rails (optional)](https://github.com/getsentry/sentry-ruby/tree/master/sentry-rails)**: Integrates Sentry with Rails for seamless error reporting.

## Contributing

Contributions are welcome! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add some feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Open a pull request.

## License

This project is open source and free to use by anyone. It is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.
