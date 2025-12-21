using Core.Entities;
using Core.Interfaces;
using Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<IPersonRepository, InMemoryPersonRepository>();
builder.Services.AddScoped<Application.Services.PersonService>();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/people", (Application.Services.PersonService svc) => Results.Ok(svc.GetPeople()));

app.MapPost("/people", (Application.Services.PersonService svc, Person person) =>
{
    svc.CreatePerson(person);
    return Results.Created($"/people/{person.Id}", person);
});

app.Run();
