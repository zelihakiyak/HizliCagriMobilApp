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
        public async Task<IActionResult> Register(User user)
        {
            // Aynı mailde kullanıcı var mı kontrol et
            if (await _context.Users.AnyAsync(u => u.Email == user.Email))
            {
                return BadRequest("Bu e-posta adresi zaten kayıtlı.");
            }

            // Gerçek projede şifreyi hashlemek gerekir, şimdilik direkt kaydediyoruz
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(user);
        }

        // POST: api/Auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto loginData)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == loginData.Email && u.Password == loginData.Password);

            if (user == null)
            {
                return Unauthorized("E-posta veya şifre hatalı.");
            }

            return Ok(user); // Kullanıcı bulundu, bilgilerini (ID, Role vs.) dön
        }
    }

    // Login için basit bir model (DTO)
    public class LoginDto
    {
        public required string Email { get; set; }
        public required string Password { get; set; }
    }
}