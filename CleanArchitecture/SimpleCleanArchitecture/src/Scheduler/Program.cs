using System;
using Core.Entities;
using Infrastructure.Data;

namespace Scheduler
{
	class Program
	{
		static void Main(string[] args)
		{
			var repository = new InMemoryPersonRepository();
			var person = new Person { Name = $"ScheduledUser_{DateTime.UtcNow:yyyyMMdd_HHmmss}" };
			repository.Add(person);
			Console.WriteLine($"Added person: {person.Name} (Id: {person.Id})");
			Console.WriteLine("Current people in repository:");
			foreach (var p in repository.GetAll())
			{
				Console.WriteLine($"- {p.Name} (Id: {p.Id})");
			}
		}
	}
}
