using System.ComponentModel.DataAnnotations;

namespace HizliCagriAPI.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty; 

        [Required]
        public string Password { get; set; } = string.Empty; 

        [Required]
        public string Role { get; set; } = string.Empty;

        public int DepartmentId { get; set; }
        public Department? Department { get; set; }
        public string? PhoneNumber { get; set; }
        public bool IsApproved { get; set; } = false;
    }
}