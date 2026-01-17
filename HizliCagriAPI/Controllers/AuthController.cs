using HizliCagriAPI.Data;
using HizliCagriAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HizliCagriAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        // POST: api/Auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] User user)
        {
            // 1. Temiz Validasyon: Gelen verilerin boş olmadığını kontrol et
            if (string.IsNullOrEmpty(user.Email) || string.IsNullOrEmpty(user.Password))
            {
                return BadRequest("E-posta ve şifre zorunludur.");
            }

            // 2. Rol Bazlı Onay Mantığı
            // Admin ve Müdür rolleri için IsApproved otomatik true, diğerleri (Sekreter) false olur.
            if (user.Role == "Admin" || user.Role == "Mudur")
            {
                user.IsApproved = true; 
            }
            else
            {
                user.IsApproved = false; 
            }

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new { 
                message = user.IsApproved ? "Kayıt başarıyla tamamlandı." : "Kayıt başarılı, Admin onayı bekleniyor." 
            });
        }
        

        // POST: api/Auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == loginDto.Email && u.Password == loginDto.Password);

            if (user == null) return Unauthorized(new { message = "Hatalı giriş" });
            if (!user.IsApproved) return BadRequest(new { message = "Onay bekleniyor" });

            // Flutter tarafı küçük harflerle (role, id, departmentId) bekliyor olabilir
            return Ok(new {
                id = user.Id,
                fullName = user.FullName,
                role = user.Role,
                departmentId = user.DepartmentId // Burası boş (null) gitmemeli
            });
        }
    }

    // Login için basit bir model (DTO)
    public class LoginDto
    {
        public required string Email { get; set; }
        public required string Password { get; set; }
    }
    public class RegisterDto
    {
        public required string FullName { get; set; }
        public required string Email { get; set; }
        public required string Password { get; set; }
        public int DepartmentId { get; set; }
        public required string Role { get; set; }
    }
}