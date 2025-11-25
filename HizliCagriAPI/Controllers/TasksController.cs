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
            taskItem.Status = "Yeni"; // İlk oluştuğunda durumu "Yeni" olsun

            _context.TaskItems.Add(taskItem);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetTaskById), new { id = taskItem.Id }, taskItem);
        }

        // GET: api/Tasks/secretary/{id}
        // Belirli bir sekretere ait görevleri getirir (Sekreter kullanır)
        [HttpGet("secretary/{id}")]
        public async Task<IActionResult> GetTasksForSecretary(int id)
        {
            var tasks = await _context.TaskItems
                .Where(t => t.AssignedToUserId == id)
                .OrderByDescending(t => t.CreatedAt) // En yeniler üstte
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
    }
}