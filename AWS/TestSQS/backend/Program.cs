using Amazon.SQS;
using Amazon.SQS.Model;
using Amazon;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register SQS client as singleton
builder.Services.AddSingleton<IAmazonSQS>(sp => new AmazonSQSClient(RegionEndpoint.EUWest1));

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
