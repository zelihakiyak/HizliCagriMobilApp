using HizliCagriAPI.Data;
using HizliCagriAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HizliCagriAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TasksController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TasksController(AppDbContext context)
        {
            _context = context;
        }

        // POST: api/Tasks
        // Yeni görev oluşturma (Müdür kullanır)
        [HttpPost]
        public async Task<IActionResult> CreateTask(TaskItem taskItem)
        {
            taskItem.CreatedAt = DateTime.Now;
            taskItem.Status = "Yeni"; 
            _context.TaskItems.Add(taskItem);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetTaskById), new { id = taskItem.Id }, taskItem);
        }

        // GET: api/Tasks/secretary/{id}
        // Belirli bir sekretere ait görevleri getirir (Sekreter kullanır)
        [HttpGet("secretary/{secretaryId}")]
        public async Task<ActionResult<IEnumerable<TaskItem>>> GetTasksBySecretary(int secretaryId)
        {
            // Veritabanında sekretere atanan görevleri filtreler
            var tasks = await _context.TaskItems
                .Include(t => t.AssignedByUser) // Müdür bilgisi için
                .Where(t => t.AssignedToUserId == secretaryId)
                .OrderByDescending(t => t.CreatedAt) 
                .ToListAsync();

            return Ok(tasks);
        }

        // GET: api/Tasks/{id}
        // Tek bir görevi getirir (Yardımcı metod)
        [HttpGet("{id}")]
        public async Task<IActionResult> GetTaskById(int id)
        {
            var task = await _context.TaskItems.FindAsync(id);
            if (task == null) return NotFound();
            return Ok(task);
        }
        
        // PUT: api/Tasks/{id}/complete
        // Görevi tamamlandı olarak işaretle
        [HttpPut("{id}/complete")]
        public async Task<IActionResult> CompleteTask(int id)
        {
            var task = await _context.TaskItems.FindAsync(id);
            if (task == null) return NotFound();

            task.Status = "Tamamlandı";
            await _context.SaveChangesAsync();

            return Ok(task);
        }
        // TasksController.cs içinde status güncelleme için daha güvenli yol:
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] dynamic data)
        {
            var task = await _context.TaskItems.FindAsync(id);
            if (task == null) return NotFound();

            // Flutter'dan gelen string'i düzgünce ayıklar
            task.Status = data.ToString(); 
            
            await _context.SaveChangesAsync();
            return Ok(new { message = "Durum güncellendi" });
        }
    }
}