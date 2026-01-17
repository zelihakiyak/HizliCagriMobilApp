using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HizliCagriAPI.Data;
using HizliCagriAPI.Models;

namespace HizliCagriAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DepartmentsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public DepartmentsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Departments (Departmanları Listele)
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Department>>> GetDepartments()
        {
            return await _context.Departments.ToListAsync();
        }

        // POST: api/Departments (Yeni Departman Ekle)
        [HttpPost]
        public async Task<ActionResult<Department>> PostDepartment(Department department)
        {
            if (string.IsNullOrEmpty(department.Name))
            {
                return BadRequest("Departman adı boş olamaz.");
            }

            _context.Departments.Add(department);
            await _context.SaveChangesAsync();

            // Başarılı olduğunda 201 Created döner
            return CreatedAtAction(nameof(GetDepartments), new { id = department.Id }, department);
        }

        // DELETE: api/Departments/5 (Departman Silme - İsteğe Bağlı)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDepartment(int id)
        {
            var department = await _context.Departments.FindAsync(id);
            if (department == null) return NotFound();

            _context.Departments.Remove(department);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        // GET: api/Departments
        [HttpGet("{id}")]
        public async Task<IActionResult> GetDepartment(int id)
        {
            var department = await _context.Departments.FindAsync(id);

            if (department == null)
            {
                return NotFound(new { message = "Bölüm bulunamadı." });
            }

            return Ok(department);
        }
    }
}