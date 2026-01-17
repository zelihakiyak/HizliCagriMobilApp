using System.ComponentModel.DataAnnotations;

namespace HizliCagriAPI.Models
{
    public class Department
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public string Name { get; set; } = string.Empty;
        public ICollection<User>? Users { get; set; }
    }
}