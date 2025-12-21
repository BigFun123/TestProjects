using System;
using System.Collections.Generic;
using Core.Entities;

namespace Core.Interfaces
{
    public interface IPersonRepository
    {
        IEnumerable<Person> GetAll();
        Person? Get(Guid id);
        void Add(Person person);
    }
}
