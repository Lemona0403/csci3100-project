# Campus Lost and Found

A Ruby on Rails application for reporting and browsing found items on campus, and for managing claims to those items.

## Current features

- Browse, search, and filter available items by facility, category, and date found.
- Submit and track claims for available items.
- Staff can manage items and review claims associated with their facility.
- Claim status filters default to pending and also support approved and rejected claims.
- Item records can include an image. JPEG, PNG, and WebP files up to 5 MB are accepted.
- Responsive interface styled with the application's purple and gold color palette.

### Claim workflow

| Action | Claim status | Item status |
| --- | --- | --- |
| A user submits a claim | Pending | Claim pending |
| Staff approves the claim | Approved | Claimed |
| Staff rejects the claim | Rejected | Available |
| A pending claim is deleted | Deleted | Available |

The database enforces at most one pending claim per item.

## Requirements

- Ruby 3.3.8 (see `lost_and_found_app/.ruby-version`)
- Bundler
- Google Chrome for browser-based system tests

The app uses SQLite for development and test databases, and stores uploaded files locally in development. It uses Rails Import Maps, so a separate JavaScript package manager is not needed for the standard setup.

## Setup and run

From the repository root, enter the Rails application directory and install its Ruby dependencies:

```sh
cd lost_and_found_app
bundle install
```

Create and migrate the database:

```sh
bin/rails db:prepare
```

Optionally load sample facilities, accounts, items, and claims:

```sh
bin/rails db:seed
```

Start the development server:

```sh
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000). You can also use `bin/setup` from `lost_and_found_app` to install dependencies and prepare the database.

### Sample accounts

After running the seeds, these local development accounts are available:

| Role | Email | Password |
| --- | --- | --- |
| General user | `user1@example.com` | `ABCabc123!@#` |
| University Library staff | `staff.ulib@example.com` | `ABCabc123!@#` |

Seed passwords are for local development only. Do not use them in a deployed environment.

## Tests

Run the Rails Minitest suite, including system tests:

```sh
bin/rails test
```

System tests use Selenium with Google Chrome. Run the Cucumber feature suite with:

```sh
bin/cucumber
```

## Application structure

The Rails application and its detailed configuration are in [`lost_and_found_app/`](lost_and_found_app/). Run Rails commands from that directory.
