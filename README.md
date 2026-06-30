## flagship-platform

"Common ground" project for all services included into flagship ecosystem

---

## Local development
To spin up the whole thing</br>
- Pull rate-limiter;
- Pull jwt-authority;
- Pull flagship;
- Pull flaghsip-platform;
- Place them inthe same folder;
- Navigate to flagship-platform;
- run command:

```bash
docker-compose up --build
```

As result you will have the containers running on ports:
- :8080 - flagship (the main flags service);
- :8000 - rate-limiter;
- :3000 - jwt-authority;
- :5432 - postgresql;
- :6379 - redis;

## Documentation

Each of the services has swagger running, accessible from `/docs`