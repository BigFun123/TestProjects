using System.Collections.Generic;
using System.Linq;
using Core.Entities;
using Core.Interfaces;

namespace Infrastructure.Data
{
    public class InMemoryPersonRepository : IPersonRepository
    {
        private readonly List<Person> _store = new()
        {
            new Person { Name = "Alice" },
            new Person { Name = "Bob" }
        };

        public IEnumerable<Person> GetAll() => _store.AsReadOnly();

        public Person? Get(System.Guid id) => _store.FirstOrDefault(p => p.Id == id);

        public void Add(Person person) => _store.Add(person);
    }
}
