Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.

## Docker

Copy the optional environment template if you need Cloudinary uploads or Mapbox autocomplete:

```sh
cp .env.example .env
```

If your host user is not `1000:1000`, update `UID` and `GID` in `.env` so generated files are owned by your user.

Build and start the app:

```sh
docker compose up --build
```

The Rails app runs at http://localhost:3000. Compose also starts internal Postgres and Redis services, plus a webpack watcher for `app/assets/builds/application.js`.
