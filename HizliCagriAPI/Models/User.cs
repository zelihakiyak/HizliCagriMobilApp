using System.ComponentModel.DataAnnotations;

namespace HizliCagriAPI.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string FullName { get; set; } = string.Empty; // Ad Soyad

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty; // Giriş için

        [Required]
        public string Password { get; set; } = string.Empty; // Şifre

        [Required]
        public string Role { get; set; } = string.Empty; // "Mudur", "Sekreter"

        public string? Company { get; set; } // Şirket Adı
    }
}