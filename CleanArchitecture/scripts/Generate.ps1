--powershell -ExecutionPolicy Bypass -File .\new-feature.ps1 -Name Order
--public DbSet<Order> Orders => Set<Order>();  // to avoid having to modify the DbContext later



param(
    [Parameter(Mandatory=$true)]
    [string]$Name
)

$entity = $Name
$plural = "${Name}s"
$camel = $Name.ToLower()

Write-Host "Scaffolding feature for $entity..."

$paths = @(
    "Domain/Entities",
    "Application/DTOs",
    "Application/Features/$plural/Commands/Create$entity",
    "Application/Features/$plural/Queries/Get$plural",
    "Application/Common/Interfaces/Repositories",
    "Infrastructure/Repositories",
    "API/Controllers"
)

foreach ($path in $paths) {
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

# 1. Entity
$entityPath = "Domain/Entities/$entity.cs"
@"
namespace Domain.Entities;

public class $entity
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
}
"@ | Set-Content $entityPath

# 2. DTO
$dtoPath = "Application/DTOs/${entity}Dto.cs"
@"
namespace Application.DTOs;

public record ${entity}Dto(
    Guid Id,
    string Name
);
"@ | Set-Content $dtoPath

# 3. Repository Interface
$repoInterfacePath = "Application/Common/Interfaces/Repositories/I${entity}Repository.cs"
@"
using Domain.Entities;

namespace Application.Common.Interfaces.Repositories;

public interface I${entity}Repository
{
    Task<$entity?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<IReadOnlyList<$entity>> GetAllAsync(CancellationToken cancellationToken);
    Task AddAsync($entity entity, CancellationToken cancellationToken);
}
"@ | Set-Content $repoInterfacePath

# 4. Repository Implementation
$repoImplPath = "Infrastructure/Repositories/${entity}Repository.cs"
@"
using Application.Common.Interfaces.Repositories;
using Domain.Entities;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class ${entity}Repository : I${entity}Repository
{
    private readonly AppDbContext _context;

    public ${entity}Repository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<$entity?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => await _context.Set<$entity>().FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    public async Task<IReadOnlyList<$entity>> GetAllAsync(CancellationToken cancellationToken)
        => await _context.Set<$entity>().ToListAsync(cancellationToken);

    public async Task AddAsync($entity entity, CancellationToken cancellationToken)
    {
        _context.Set<$entity>().Add(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
"@ | Set-Content $repoImplPath

# 5. Create Command
$commandPath = "Application/Features/$plural/Commands/Create$entity/Create${entity}Command.cs"
@"
using MediatR;
using Application.DTOs;

namespace Application.Features.$plural.Commands.Create$entity;

public record Create${entity}Command(string Name) : IRequest<${entity}Dto>;
"@ | Set-Content $commandPath

# 6. Create Handler
$handlerPath = "Application/Features/$plural/Commands/Create$entity/Create${entity}Handler.cs"
@"
using MediatR;
using Application.DTOs;
using Application.Common.Interfaces.Repositories;
using Domain.Entities;

namespace Application.Features.$plural.Commands.Create$entity;

public class Create${entity}Handler : IRequestHandler<Create${entity}Command, ${entity}Dto>
{
    private readonly I${entity}Repository _repository;

    public Create${entity}Handler(I${entity}Repository repository)
    {
        _repository = repository;
    }

    public async Task<${entity}Dto> Handle(Create${entity}Command request, CancellationToken cancellationToken)
    {
        var entity = new $entity
        {
            Id = Guid.NewGuid(),
            Name = request.Name
        };

        await _repository.AddAsync(entity, cancellationToken);

        return new ${entity}Dto(entity.Id, entity.Name);
    }
}
"@ | Set-Content $handlerPath

# 7. Query
$queryPath = "Application/Features/$plural/Queries/Get$plural/Get${plural}Query.cs"
@"
using MediatR;
using Application.DTOs;
using System.Collections.Generic;

namespace Application.Features.$plural.Queries.Get$plural;

public record Get${plural}Query() : IRequest<IReadOnlyList<${entity}Dto>>;
"@ | Set-Content $queryPath

# 8. Query Handler
$queryHandlerPath = "Application/Features/$plural/Queries/Get$plural/Get${plural}Handler.cs"
@"
using MediatR;
using Application.DTOs;
using Application.Common.Interfaces.Repositories;

namespace Application.Features.$plural.Queries.Get$plural;

public class Get${plural}Handler : IRequestHandler<Get${plural}Query, IReadOnlyList<${entity}Dto>>
{
    private readonly I${entity}Repository _repository;

    public Get${plural}Handler(I${entity}Repository repository)
    {
        _repository = repository;
    }

    public async Task<IReadOnlyList<${entity}Dto>> Handle(Get${plural}Query request, CancellationToken cancellationToken)
    {
        var entities = await _repository.GetAllAsync(cancellationToken);
        return entities.Select(x => new ${entity}Dto(x.Id, x.Name)).ToList();
    }
}
"@ | Set-Content $queryHandlerPath

# 9. Controller
$controllerPath = "API/Controllers/${plural}Controller.cs"
@"
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Application.Features.$plural.Commands.Create$entity;
using Application.Features.$plural.Queries.Get$plural;

namespace API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ${plural}Controller : ControllerBase
{
    private readonly IMediator _mediator;

    public ${plural}Controller(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> Get(CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new Get${plural}Query(), cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Create${entity}Command command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return Ok(result);
    }
}
"@ | Set-Content $controllerPath

Write-Host "✅ Feature scaffolding complete for $entity"
