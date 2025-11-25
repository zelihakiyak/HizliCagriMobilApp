using HizliCagriAPI.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HizliCagriAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Users/secretaries
        // Sadece sekreterleri getirir
        [HttpGet("secretaries")]
        public async Task<IActionResult> GetSecretaries()
        {
            var secretaries = await _context.Users
                .Where(u => u.Role == "Sekreter")
                .ToListAsync();

            return Ok(secretaries);
        }
    }
}