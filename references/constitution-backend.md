---
agent: speckit.constitution
---

## Skills Reference

Before starting the planning workflow, check if relevant Cursor skills apply to the feature being planned.

# Project Constitution - Coding Principles and Standards

## 1. Architecture Principles - Hexagonal Architecture (Ports & Adapters)

### Core Concepts
- **Domain at the Center**: Business logic is completely isolated from external concerns
- **Ports**: Interfaces that define how the application interacts with the outside world
- **Adapters**: Concrete implementations that connect external systems to ports
- **Dependency Rule**: All dependencies point toward the center (domain and use cases)
- **Technology Independence**: The core domain doesn't know about databases, frameworks, or UI

### Hexagonal Architecture Flow
```
[Inbound Adapters] -> [Ports] -> [Use Cases] -> [Ports] -> [Outbound Adapters]
    (Drivers)                      (CORE)                      (Driven)
```

### Directory Structure

**Important**: The `/app` directory must be created if it does not exist before starting any project structure implementation.

```
/app
  /src
    /domain
      /commands    # Input DTOs (Pydantic models) for use cases
      /entities    # Core business entities and domain models
      /exceptions  # Domain-specific exceptions

    /use_cases     # Application core (*_usecase.py files ONLY)
                   # Business rules orchestration

    /ports         # Interfaces (contracts)
      i_*_repository.py    # Outbound ports for data persistence
      i_*_service.py       # Outbound ports for external services
      i_*_publisher.py     # Outbound ports for message publishing

    /adapters
      /inbound      # Inbound adapters (primary/driving)
        *_controller.py     # REST/HTTP/GraphQL endpoints
        *_consumer.py       # Message queue consumers (SQS, Kafka)
        *_listener.py       # Event subscribers, webhooks
        *_handler.py        # Lambda handlers, entry points
        *_command.py        # CLI commands

      /outbound     # Outbound adapters (secondary/driven)
        *_repository.py     # Database/persistence implementations
        *_api_client.py     # External REST/GraphQL API clients
        *_publisher.py      # Message queue publishers
        *_storage.py        # File storage services (S3, filesystem)
        *_service.py        # External services (email, SMS, notifications)

    /tests
      /unit         # Unit tests mirroring src structure
        /adapters
          /inbound      # Tests for inbound adapters
          /outbound     # Tests for outbound adapters
        /use_cases    # Tests for use cases (core business logic)
      /fixtures         # Test fixtures and mocks
```

### Hexagonal Architecture Layers

#### Layer 1: Domain (Center)
**Location**: `/app/src/domain`
**Purpose**: Pure business entities and value objects
**Dependencies**: None (completely isolated)
**Contains**:
- Entities: Core business objects (User, Order, Product)
- Value Objects: Immutable domain values (Email, Money, Address)
- Domain Events: Business events
- Domain Exceptions: Business rule violations

#### Layer 2: Application Core (Use Cases)
**Location**: `/app/src/use_cases`
**Purpose**: Orchestrate business workflows
**Dependencies**: Only domain entities and port interfaces
**Contains**:
- Use case classes implementing application business rules
- Input/Output DTOs coordination

#### Layer 3: Ports (Interfaces)
**Location**: `/app/src/ports`
**Purpose**: Define contracts for adapters
**Dependencies**: Only domain entities
**Contains**:
- Inbound ports (use case interfaces, if needed)
- Outbound ports (repository, service, publisher interfaces)

#### Layer 4: Adapters (Outside)
**Location**: `/app/src/adapters/inbound` and `/app/src/adapters/outbound`
**Purpose**: Connect external world to application core
**Dependencies**: Ports, domain, infrastructure libraries

**Inbound Adapters** (`/app/src/adapters/inbound`):
- REST API controllers
- Message queue consumers
- Event subscribers
- CLI adapters
- GraphQL resolvers

**Outbound Adapters** (`/app/src/adapters/outbound`):
- Repository implementations
- External API clients
- Message publishers
- Storage services

### Separation of Concerns
- Each file should have a single, well-defined purpose
- Keep classes small and focused
- Extract complex logic into separate methods or classes
- Inbound adapters handle only request/response transformation
- Use cases contain only business orchestration
- Outbound adapters handle only external system communication

### Dependency Injection
- Use constructor injection for dependencies
- Depend on interfaces (ports), not concrete implementations
- Make dependencies explicit
- Use cases receive port implementations via constructor

### Inbound Adapters (Primary/Driving Adapters)
**Purpose**: Receive requests from external sources and invoke use cases

**Location**: `/app/src/adapters/inbound`

**Examples**:
- REST API controllers (HTTP endpoints)
- Message queue consumers (SQS, RabbitMQ, Kafka)
- Event subscribers (EventBridge, SNS)
- CLI commands
- GraphQL resolvers
- gRPC services
- WebSocket listeners

**Responsibilities**:
- Parse and validate incoming requests
- Convert external data to domain commands (InputCommand)
- Invoke appropriate use cases
- Convert use case results to external format (HTTP responses, messages)
- Handle protocol-specific concerns (status codes, acknowledgments)

**Rules**:
- Must NOT contain business logic
- Must NOT access databases or external services directly
- Must depend on use case interfaces (ports), not concrete implementations
- File naming conventions:
  - `*_controller.py` for REST/HTTP/GraphQL endpoints
  - `*_consumer.py` for message queue consumers (SQS, Kafka, RabbitMQ)
  - `*_listener.py` for event subscribers and webhooks
  - `*_handler.py` for Lambda handlers and generic entry points
  - `*_command.py` for CLI commands

### Use Cases (Application Core)
**Purpose**: Orchestrate business logic and enforce business rules

**Location**: `/app/src/use_cases` (MANDATORY)

**File Naming**: MUST have the `*_usecase.py` suffix

**Examples**:
- `activate_user_usecase.py`
- `process_payment_usecase.py`
- `create_order_usecase.py`
- `send_notification_usecase.py`

**Responsibilities**:
- Implement application business rules
- Orchestrate domain entities and services
- Coordinate interactions between domain and outbound ports
- Return domain DTOs or entities

**Rules**:
- MUST be placed inside the `/app/src/use_cases` folder
- Each use case file should contain a single use case class
- File name should match the use case class in snake_case format
- Must NOT import infrastructure libraries (boto3, requests, sqlalchemy)
- Must NOT know about HTTP, SQS, databases, or any external protocol
- Must depend only on ports (interfaces), never on concrete adapters

### Outbound Adapters (Secondary/Driven Adapters)
**Purpose**: Implement outbound ports to interact with external systems

**Location**: `/app/src/adapters/outbound`

**Examples**:
- Database repositories (DynamoDB, PostgreSQL, MongoDB)
- External API clients (REST APIs, GraphQL)
- Message producers (SQS, SNS, EventBridge)
- File storage (S3)
- Cache services (Redis, ElastiCache)
- Email/SMS services (SES, SNS)

**Responsibilities**:
- Implement outbound port interfaces
- Handle external system protocols and formats
- Convert domain entities to external formats
- Manage connections and error handling

**Rules**:
- Must implement port interfaces defined in `/app/src/ports`
- File naming conventions:
  - `*_repository.py` for database/persistence implementations
  - `*_api_client.py` for external REST/GraphQL API clients
  - `*_publisher.py` for message queue publishers (SQS, SNS, Kafka)
  - `*_storage.py` for file storage services (S3, filesystem)
  - `*_service.py` for external services (email, SMS, notifications)
- Can import infrastructure libraries (boto3, requests, etc.)
- Must NOT contain business logic

### Ports (Interfaces)
**Purpose**: Define contracts between core and adapters

**Location**: `/app/src/ports`

**Types**:
- **Inbound Ports**: Interfaces that use cases expose to inbound adapters (often just the use case class itself)
- **Outbound Ports**: Interfaces that use cases depend on (repositories, external services)

**Naming Convention**:
- Interface Format: CamelCase with `I` prefix
- Examples: `IUserRepository`, `IPaymentService`, `INotificationService`, `IMetadataService`

**Rules**:
- Must be abstract (use ABC or Protocol)
- Must NOT contain implementation details
- Must be defined in `/app/src/ports` directory

## 2. Naming Conventions

### Classes
- **Format**: CamelCase (PascalCase)
- **Examples**:
  - `UserAccount`
  - `OrderProcessor`
  - `PaymentGateway`
  - `CustomerRepository`
- **Rules**:
  - Use nouns or noun phrases
  - Be descriptive and specific
  - Avoid abbreviations unless widely recognized

### Interfaces (Ports)
- **Format**: CamelCase with `I` prefix
- **Naming Philosophy**: Names must reflect **business concepts** and **capabilities**, NOT technology or vendor specifics
- **Examples (Business-Oriented)**:
  - `IUserRepository` (outbound port - stores/retrieves users)
  - `IPaymentGateway` (outbound port - processes payments)
  - `INotificationSender` (outbound port - sends notifications)
  - `IMetadataProvider` (outbound port - provides metadata)
  - `IOrderStorage` (outbound port - persists orders)
  - `ICustomerFinder` (outbound port - finds customers)
  - `IDocumentPublisher` (outbound port - publishes documents)
  - `IEmailDispatcher` (outbound port - dispatches emails)
- **Rules**:
  - Always start with capital `I`
  - Followed by CamelCase name
  - Describe **what the port does** (business capability), not **how it does it**
  - Use business domain terms, not technical implementation terms
  - Placed in `/app/src/ports` directory
- **AVOID (Technology/Vendor-Specific)**:
  - `IDynamoDBRepository` - tied to AWS DynamoDB
  - `ISQSPublisher` - tied to AWS SQS
  - `ISESService` - tied to AWS SES
  - `IRedisCache` - tied to Redis
  - `IPostgreSQLRepository` - tied to PostgreSQL
- **PREFER (Business-Oriented)**:
  - `IUserRepository` - can be implemented with DynamoDB, PostgreSQL, MongoDB, etc.
  - `IMessagePublisher` - can be implemented with SQS, Kafka, RabbitMQ, etc.
  - `IEmailSender` - can be implemented with SES, SendGrid, SMTP, etc.
  - `ICacheProvider` - can be implemented with Redis, Memcached, in-memory, etc.
  - `ICustomerStorage` - can be implemented with any database technology

### Inbound Adapters
- **Format**: snake_case with specific suffix based on type
- **File Suffixes**:
  - `*_controller.py` - REST/HTTP/GraphQL endpoints
  - `*_consumer.py` - Message queue consumers
  - `*_listener.py` - Event subscribers, webhooks
  - `*_handler.py` - Lambda handlers, entry points
  - `*_command.py` - CLI commands
- **Examples**:
  - `databases_get_controller.py` (REST endpoint)
  - `order_created_consumer.py` (SQS/Kafka consumer)
  - `payment_webhook_listener.py` (Webhook subscriber)
  - `import_data_handler.py` (Lambda handler)
  - `migrate_database_command.py` (CLI command)
- **Class Names**: CamelCase matching file suffix
  - `DatabasesGetController`
  - `OrderCreatedConsumer`
  - `PaymentWebhookListener`
  - `ImportDataHandler`
  - `MigrateDatabaseCommand`

### Use Cases
- **Format**: snake_case with `_usecase.py` suffix (MANDATORY)
- **Examples**:
  - `list_databases_usecase.py`
  - `process_order_usecase.py`
  - `send_notification_usecase.py`
- **Class Names**: CamelCase ending with `UseCase`
  - `ListDatabasesUseCase`
  - `ProcessOrderUseCase`
  - `SendNotificationUseCase`

### Outbound Adapters
- **Format**: snake_case with specific suffix based on type
- **File Suffixes**:
  - `*_repository.py` - Database/persistence implementations
  - `*_api_client.py` - External REST/GraphQL API clients
  - `*_publisher.py` - Message queue publishers
  - `*_storage.py` - File storage services
  - `*_service.py` - External services (email, SMS)
- **Examples**:
  - `dynamodb_repository.py` (database)
  - `atlan_api_client.py` (external API)
  - `sqs_publisher.py` (message queue)
  - `s3_storage.py` (file storage)
  - `ses_email_service.py` (email service)
- **Class Names**: CamelCase matching file suffix
  - `DynamoDBRepository`
  - `AtlanApiClient`
  - `SQSPublisher`
  - `S3Storage`
  - `SESEmailService`

### Methods
- **Format**: snake_case
- **Examples**:
  - `get_user_by_id()`
  - `process_payment()`
  - `validate_order_data()`
  - `send_confirmation_email()`
- **Rules**:
  - Use verbs or verb phrases
  - Be descriptive of the action performed
  - Keep names concise but clear

### Variables
- **Format**: snake_case
- **Examples**:
  - `user_id`
  - `total_amount`
  - `is_active`
  - `customer_list`

### Constants
- **Format**: UPPER_SNAKE_CASE
- **Examples**:
  - `MAX_RETRY_ATTEMPTS`
  - `DEFAULT_TIMEOUT`
  - `API_BASE_URL`

## 3. Testing Strategy

### Unit Testing - MANDATORY
- **Coverage**: Write unit tests for all business logic and use cases
- **Isolation**: Tests must be isolated and independent
- **Mocking**: Use mocks and stubs for external dependencies
- **Naming Convention**: `test_<method_name>_<scenario>_<expected_result>`
- **Examples**:
  - `test_get_user_by_id_valid_id_returns_user()`
  - `test_process_payment_insufficient_funds_raises_exception()`
  - `test_validate_order_data_missing_field_returns_false()`
- **Structure**: Follow AAA pattern (Arrange, Act, Assert)
- **Fast Execution**: Tests should run quickly (< 1 second per test)
- **No External Dependencies**: No database, network, or file system calls

### Integration Testing - PROHIBITED
- **Do NOT write integration tests**
- **Do NOT test**:
  - Database connections
  - External API calls
  - File system operations
  - Multiple layers/components together
- **Rationale**: Focus on unit-level verification only

## 4. SOLID Principles

### Single Responsibility Principle (SRP)
- A class should have only one reason to change
- One class, one responsibility

### Open/Closed Principle (OCP)
- Open for extension, closed for modification
- Use interfaces and abstract classes for extensibility

### Liskov Substitution Principle (LSP)
- Subtypes must be substitutable for their base types
- Derived classes must not break base class contracts

### Interface Segregation Principle (ISP)
- Clients should not depend on interfaces they don't use
- Keep interfaces small and focused

### Dependency Inversion Principle (DIP)
- Depend on abstractions, not concretions
- High-level modules should not depend on low-level modules

## 5. Code Quality Standards

### Documentation
- Add docstrings to all public classes and methods
- Include parameter descriptions and return types
- Document exceptions that can be raised

### Error Handling
- Use specific exception types
- Handle errors at appropriate layers
- Never silence exceptions without logging

### Code Formatting
- Use consistent indentation (4 spaces)
- Maximum line length: 100 characters
- Use blank lines to separate logical sections

### Data Structures
- **Prioritize Objects over Dictionaries**
- **Use DTOs (Data Transfer Objects) and Commands for data exchange between layers**
- **Rules**:
  - DO: Use Pydantic models for structured data
  - DO: Define explicit classes with typed attributes
  - DO: Use Commands (located in `/app/src/domain/commands`) for use case inputs
  - DO: Use DTOs for data transfer between layers
  - DO: Leverage type checking and Cursor autocompletion
  - DO: Use Pydantic BaseModel for validation and serialization
  - DON'T: Use plain dictionaries or JSON for structured data
  - DON'T: Pass untyped dictionaries between layers
  - DON'T: Rely on string keys that can be mistyped
  - DON'T: Pass raw request/response objects to use cases
- **Examples**:
```python
# BAD: Using plain dictionaries
user_data = {
    "name": "John",
    "email": "john@example.com",
    "age": 30
}
process_user(user_data)  # No type safety!

# GOOD: Using Command (for use case input)
# Location: /app/src/domain/commands/create_user_command.py
from pydantic import BaseModel, EmailStr

class CreateUserCommand(BaseModel):
    name: str
    email: EmailStr
    age: int

command = CreateUserCommand(name="John", email="john@example.com", age=30)
use_case.execute(command)  # Type-safe!

# GOOD: Using DTO (for data transfer)
# Location: /app/src/domain/entities/user.py or dedicated DTOs folder
from pydantic import BaseModel

class UserDTO(BaseModel):
    id: str
    name: str
    email: str
    age: int
    created_at: str

user_dto = UserDTO(id="123", name="John", email="john@example.com",
                   age=30, created_at="2026-01-23")
```
- **Data Flow Pattern**:
  `Inbound Adapter -> Command -> Use Case -> Entity/DTO -> Outbound Port -> Adapter`
- **Rationale**: Objects, DTOs, and Commands provide type safety, better Cursor support, validation, clear contracts between layers, and make code more maintainable and less error-prone

### Type Hints
- Use type hints for all function parameters and return values
- Leverage static type checking tools

### Parameter Passing - Named Arguments
- **Always use named arguments when calling methods and constructors**
- **Rules**:
  - DO: Use keyword arguments for all parameters
  - DO: Make code explicit and self-documenting
  - DO: Improve code readability and maintainability
  - DO: Prevent errors from incorrect parameter ordering
  - DON'T: Use positional arguments
  - DON'T: Rely on parameter order
- **Examples**:
```python
# BAD: Positional arguments
user = User("John", "john@example.com", 30, True)
result = process_payment(order_id, 100.50, "USD", True)
repository.find_by_id("123")

# GOOD: Named arguments
user = User(
    name="John",
    email="john@example.com",
    age=30,
    is_active=True
)

result = process_payment(
    order_id=order_id,
    amount=100.50,
    currency="USD",
    send_confirmation=True
)

repository.find_by_id(user_id="123")

# ACCEPTABLE: Single obvious parameter
len(my_list)  # OK - single parameter, meaning is clear
print(message)  # OK - single parameter, meaning is clear
```
- **Rationale**: Named arguments make code more readable, prevent mistakes from parameter ordering, and make refactoring safer when parameter order changes

### Global Variables - PROHIBITED
- **Never use global variables** for state, configuration, or shared data
- **Alternatives**:
  - ✅ Use dependency injection
  - ✅ Pass state as function parameters
  - ✅ Use class instances for encapsulation
  - ✅ Constants (UPPER_SNAKE_CASE) for immutable values only
- **Examples**:
```python
# BAD: Global state
current_user = None
def login(user):
    global current_user
    current_user = user
```

### Import Standards
- **Full Import Path - MANDATORY**
- **Import Policy**: All imports in application code and unit tests must use the full import path starting from `app`
- **Rules**:
  - DO: Use absolute imports starting with `app`
  - DO: Import from the full path (e.g., `from app.src.domain.entities.user import User`)
  - DO: Apply this rule to both production code and test files
  - DON'T: Use relative imports (e.g., `from ..entities import User`)
  - DON'T: Use partial paths (e.g., `from domain.entities import User`)
  - DON'T: Skip the `app` prefix
- **Examples**:
```python
# BAD: Relative imports
from ..entities.user import User
from ...ports.i_user_repository import IUserRepository

# BAD: Partial imports
from domain.entities.user import User
from src.ports.i_user_repository import IUserRepository

# GOOD: Full imports starting with app
from app.src.domain.entities.user import User
from app.src.ports.i_user_repository import IUserRepository
from app.src.use_cases.create_user_usecase import CreateUserUseCase
from app.src.adapters.outbound.user_repository import UserRepository
from app.src.domain.commands.create_user_command import CreateUserCommand
```
- **Rationale**: Using full imports starting from `app` ensures consistency, eliminates ambiguity, improves Cursor navigation, and makes code more maintainable across the entire project

### File Organization
- **`__init__.py` File Policy**: No code, docstrings, or imports should ever be placed in any `__init__.py` file. These files must remain completely empty to ensure clarity and maintain project standards.

### Code Maintenance
- **Deprecation Policy**: Regularly analyze code for deprecated methods, libraries, or APIs. Avoid using deprecated functionality to ensure long-term maintainability and compatibility.
- **Deprecation Detection**:
  - **Installation**: Add Ruff as a development dependency with uv:
    ```bash
    uv add --dev ruff
    ```
  - **Run Deprecation Check**:
    ```bash
    uv run ruff check --select=deprecated
    ```
- **Rules**:
  - DO: Review code for deprecation warnings during development
  - DO: Update deprecated code to current alternatives
  - DO: Monitor library updates for deprecation notices
  - DO: Run deprecation checks regularly (e.g., in pre-commit hooks or CI)
  - DON'T: Use methods marked as deprecated
  - DON'T: Ignore deprecation warnings

## 6. Key Reminders - Hexagonal Architecture

### Data Flow (Request -> Response)
```
1. External Request (REST API, Message Queue, Event, CLI)
   ↓
2. Inbound Adapter - converts to domain command
   ↓
3. Use Case (Core) - executes business logic
   ↓
4. Outbound Port (Interface) - defines contract
   ↓
5. Outbound Adapter - accesses external system (DB, API, Queue)
   ↓
6. Use Case - receives result
   ↓
7. Inbound Adapter - converts to external format
   ↓
8. External Response
```

**DO**:
- DO: Follow hexagonal architecture strictly (Ports & Adapters)
- DO: Keep domain and use cases isolated from external concerns
- DO: Use CamelCase for classes, `I` prefix for port interfaces
- DO: Use snake_case for methods and variables
- DO: Write comprehensive unit tests with AAA pattern
- DO: Mock outbound ports in use case tests
- DO: Mock use cases in inbound adapter tests
- DO: Apply SOLID principles
- DO: Place all use cases in `/use_cases` folder with `*_usecase.py` suffix
- DO: Place all inbound adapters in `/adapters/inbound` folder
- DO: Place all outbound adapters in `/adapters/outbound` folder
- DO: Place all ports in `/ports` folder with `i_*` prefix
- DO: Make adapters depend on ports, never the reverse
- DO: Keep inbound adapters thin (only transformation logic)
- DO: Keep use cases focused on business rules
- DO: Inject dependencies via constructor

**DON'T**:
- DON'T: Write integration tests
- DON'T: Mix business logic in inbound adapters
- DON'T: Import infrastructure libraries (boto3, requests, sqlalchemy) in use cases or domain
- DON'T: Access databases directly from inbound adapters
- DON'T: Create circular dependencies
- DON'T: Let use cases know about HTTP, messaging protocols, or any external protocol
- DON'T: Place business logic in adapters
- DON'T: Make domain depend on use cases or adapters
- DON'T: Make use cases depend on concrete adapter implementations
- DON'T: Ignore type hints or skip documentation
- DON'T: Violate the dependency rule (dependencies must point inward)
- DON'T: Place use cases outside `/use_cases` folder
- DON'T: Use exceptions for control flow
- DON'T: Generate CI/CD pipelines or IaC templates (SAM, CDK, Terraform, CloudFormation, GitHub Actions, etc.)

### Hexagonal Architecture Checklist

When creating a new feature:
1. Define domain entities in `/app/src/domain/entities`
2. Create input command in `/app/src/domain/commands`
3. Define outbound ports in `/app/src/ports` (if needed)
4. Implement use case in `/app/src/use_cases/*_usecase.py`
5. Implement outbound adapters in `/app/src/adapters/outbound`
6. Implement inbound adapter in `/app/src/adapters/inbound`
7. Write unit tests for use case (mock outbound ports)
8. Write unit tests for adapters
9. Verify no infrastructure imports in use cases
10. Verify dependencies point inward

## 7. Skills Reference

> **For Cursor Agents**: Refer to the appropriate Cursor skills for detailed implementation guides.

`.cursor/skills/` (or project/user skills) contains skills to assist coding tasks in Cursor IDE.

## 8. CI/CD and Infrastructure-as-Code - OUT OF SCOPE

**IMPORTANT**: This constitution focuses exclusively on **application code**. Do NOT generate:

- DON'T: CI/CD pipeline configurations (GitHub Actions, GitLab CI, Jenkins, etc.)
- DON'T: Infrastructure-as-Code templates (AWS SAM, CDK, Terraform, CloudFormation, Pulumi, etc.)
- DON'T: Deployment scripts or Dockerfiles for deployment
- DON'T: Kubernetes manifests or Helm charts

**Rationale**: Infrastructure and deployment concerns are managed separately by dedicated teams and tooling. Focus on clean, testable application code only.

## 9. Development Environment Standards

### Package Manager - uv (MANDATORY)
- **Tooling Policy**: Use **uv** for all Python environment and dependency operations. Do not use `pip`, `venv`, or `requirements.txt` / `requirements-tests.txt`.
- **Virtual Environment**: uv manages `.venv` in the project root. Prefer `uv run` / `uv sync` over manual activation.
- **Setup**
  - Location: Project root directory
  - Environment name: `.venv` (created/managed by uv)
  - If the project is not initialized, create `pyproject.toml` before installing dependencies
- **Common Commands**
  - Initialize project (if needed): `uv init`
  - Create/sync environment from lockfile: `uv sync`
  - Sync including dev/test groups: `uv sync --group dev` (or `--all-groups`)
  - Run a command in the environment: `uv run <command>`
  - Run tests: `uv run pytest`
- **Workflow**
  - Ensure `pyproject.toml` exists in the project root
  - Run `uv sync` (with the appropriate groups) to install dependencies
  - Execute Python tools via `uv run` (e.g., `uv run pytest`, `uv run ruff check`)
- **Rules**
  - DO: Use uv for install, sync, add, remove, and run
  - DO: Add `.venv/` to `.gitignore`
  - DO: Commit `pyproject.toml` and `uv.lock`
  - DO: Document uv usage in `README.md`
  - DON'T: Use `pip install` or `python -m pip`
  - DON'T: Use `python -m venv` for environment creation
  - DON'T: Use system-wide Python for project dependencies
  - DON'T: Commit virtual environment files to version control

### Dependency Management
- **pyproject.toml - MANDATORY**
- **Structure**: All Python projects must declare dependencies in a single `pyproject.toml` **in the project root directory**, using production dependencies and a separate dev/test group.
  - Production dependencies: `[project.dependencies]`
  - Dev/test dependencies: `[dependency-groups]` → `dev` (or equivalent group name used consistently in the project)
  - Example:
    ```toml
    [project]
    name = "app"
    version = "0.1.0"
    requires-python = ">=3.12"
    dependencies = [
        "boto3==1.34.0",
        "pydantic==2.5.0",
        "requests==2.31.0",
    ]

    [dependency-groups]
    dev = [
        "pytest==7.4.0",
        "pytest-cov==4.1.0",
        "pytest-mock==3.11.1",
        "pylint==3.0.0",
        "ruff>=0.6.0",
    ]
    ```
- **Installation / Sync**
  - Production-only:
    ```bash
    uv sync --no-dev
    ```
  - Development/Testing (includes production + dev group):
    ```bash
    uv sync --group dev
    ```
  - Add packages:
    ```bash
    # Production
    uv add boto3

    # Dev/test
    uv add --dev pytest
    ```
- **Rules**
  - DO: Pin specific versions for application dependencies (prefer `==`)
  - DO: Keep `pyproject.toml` in the project root
  - DO: Keep test/dev tools in a dependency group (never mixed into production-only intent without being explicit)
  - DO: Update `pyproject.toml` (via `uv add` / `uv remove`) when changing packages
  - DO: Commit `uv.lock` for reproducible installs
  - DON'T: Use `requirements.txt` or `requirements-tests.txt`
  - DON'T: Use version ranges for production app dependencies when pin is possible
  - DON'T: Place dependency manifests in subdirectories
  - DON'T: Use pip to manage project dependencies

---

**Remember**: These principles ensure maintainable, testable, and scalable code. Consistency is key!

