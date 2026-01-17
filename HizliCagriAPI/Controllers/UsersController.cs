using HizliCagriAPI.Data;
using HizliCagriAPI.Models;
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

        // 1. Onay Bekleyen Sekreterleri Getir
        [HttpGet("pending")]
        public async Task<ActionResult<IEnumerable<User>>> GetPendingUsers()
        {
            return await _context.Users
                .Where(u => u.IsApproved == false && u.Role == "Sekreter")
                .ToListAsync();
        }

        // 2. Kullanıcıyı Onayla
        [HttpPut("{id}/approve")]
        public async Task<IActionResult> ApproveUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null) return NotFound(new { message = "Kullanıcı bulunamadı." });

            user.IsApproved = true;
            await _context.SaveChangesAsync();
            return Ok(new { message = $"{user.FullName} başarıyla onaylandı." });
        }

        // 3. Admin Tarafından Müdür Eklenmesi (Türkçe Karakter Fix ve Log)
        [HttpPost("add-manager")]
        public async Task<IActionResult> AddManager([FromBody] User manager)
        {
            // DEBUG: Gelen ismi konsola yazdır (Türkçe karakterler burada bozuksa sorun Flutter'dadır)
            Console.WriteLine($"Gelen Müdür İsmi: {manager.FullName}");

            if (string.IsNullOrEmpty(manager.FullName))
            {
                return BadRequest(new { message = "İsim alanı boş olamaz." });
            }

            manager.Role = "Mudur"; 
            manager.IsApproved = true; 

            if (await _context.Users.AnyAsync(u => u.Email == manager.Email))
            {
                return BadRequest(new { message = "Bu e-posta adresi zaten kullanımda." });
            }

            try 
            {
                _context.Users.Add(manager);
                await _context.SaveChangesAsync();
                return Ok(new { message = "Yeni Müdür başarıyla eklendi." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Veritabanı hatası: " + ex.Message });
            }
        }

        // 4. Departmana Göre Sekreterleri Getir (Kritik Güncelleme!)
        // Müdür sadece kendi departmanındaki sekreterleri görmeli
        [HttpGet("secretaries/{departmentId}")]
        public async Task<ActionResult<IEnumerable<User>>> GetSecretariesByDept(int departmentId)
        {
            var secretaries = await _context.Users
                .Where(u => u.Role == "Sekreter" && u.IsApproved == true && u.DepartmentId == departmentId)
                .ToListAsync();

            return Ok(secretaries);
        }
        [HttpGet("manager-of-dept/{deptId}")]
        public async Task<IActionResult> GetManagerOfDepartment(int deptId)
        {
            var manager = await _context.Users
                .FirstOrDefaultAsync(u => u.DepartmentId == deptId && u.Role == "Mudur");

            if (manager == null) return NotFound("Bu departmana atanmış bir müdür bulunamadı.");

            return Ok(new { id = manager.Id, fullName = manager.FullName });
        }
        
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUser(int id)
        {
            // Veritabanında kullanıcıyı ara
            var user = await _context.Users.FindAsync(id);

            if (user == null)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            return Ok(user);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Kullanıcı başarıyla silindi." });
        }
    }
}