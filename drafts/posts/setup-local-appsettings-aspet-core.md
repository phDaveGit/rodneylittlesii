Title: Adding an local developer configuration for ASPNETCORE
Drafted: 07/22/2017
Published: 02/15/2019
Tags:
    - ASPNETCORE
---


https://docs.microsoft.com/en-us/aspnet/core/fundamentals/environments?view=aspnetcore-2.2

# The problem statement

- As a Developer I want to have custom connection strings that don't get committed to the repository

### We should be able to set a custom `ASPENTCORE_ENVIRONMENT` variable

https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-2.2#default-configuration

### Then we should set an `appsettings.local.json`
https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-2.2#file-configuration-provider
https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/?view=aspnetcore-2.2#json-configuration-provider