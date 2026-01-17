using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HizliCagriAPI.Data; // Kendi DbContext namespace'ini ekle
using HizliCagriAPI.Models;
[Route("api/[controller]")]
[ApiController]
public class AdminController : ControllerBase
{
    private readonly AppDbContext _context;

    public AdminController(AppDbContext context)
    {
        _context = context;
    }

    // GEREKSİNİM: Tüm çağrı kayıtlarını detaylı listeleme 
    [HttpGet("all-logs")]
public async Task<IActionResult> GetAllLogs()
{
    // TaskItem tablosunu sorguluyoruz çünkü detaylar burada
    var logs = await _context.TaskItems
        .Include(t => t.AssignedByUser) // Müdür bilgisi için
        .Include(t => t.AssignedToUser) // Sekreter bilgisi için
        .OrderByDescending(t => t.CreatedAt)
        .Select(t => new {
            Id = t.Id,
            Title = t.Title,
            Description = t.Description,
            UrgencyLevel = t.UrgencyLevel,
            Status = t.Status,
            CreatedAt = t.CreatedAt,
            SenderName = t.AssignedByUser != null ? t.AssignedByUser.FullName : "Sistem",
            ReceiverName = t.AssignedToUser != null ? t.AssignedToUser.FullName : "Bilinmeyen"
        })
        .ToListAsync();

    return Ok(logs);
}
}