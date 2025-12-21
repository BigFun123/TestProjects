using System;
using System.Collections.Generic;
using Core.Entities;
using Core.Interfaces;

namespace Application.Services
{
    public class PersonService
    {
        private readonly IPersonRepository _repo;

        public PersonService(IPersonRepository repo)
        {
            _repo = repo;
        }

        public IEnumerable<Person> GetPeople() => _repo.GetAll();

        public void CreatePerson(Person person) => _repo.Add(person);
    }
}
