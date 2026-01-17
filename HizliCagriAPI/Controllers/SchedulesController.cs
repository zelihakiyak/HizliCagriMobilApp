using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HizliCagriAPI.Data;
using HizliCagriAPI.Models;

namespace HizliCagriAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SchedulesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SchedulesController(AppDbContext context)
        {
            _context = context;
        }

        // 1. Yeni Program Oluştur
        [HttpPost]
        public async Task<ActionResult<ScheduleItem>> CreateSchedule(ScheduleItem item)
        {
            if (item == null) return BadRequest("Geçersiz veri.");
            
            item.IsApproved = false; 
            item.Status = "Pending"; // Başlangıç durumu
            
            _context.ScheduleItems.Add(item);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetScheduleById), new { id = item.Id }, item);
        }

        // 2. Onay Bekleyenleri Getir (Flutter Servisindeki pending/id için)
        [HttpGet("pending/{managerId}")]
        public async Task<ActionResult<IEnumerable<ScheduleItem>>> GetPendingSchedules(int managerId)
        {
            // Not: Eğer departmentId kullanıyorsan managerId yerine User tablosu ile join gerekebilir.
            // Şimdilik managerId üzerinden filtreliyoruz.
            return await _context.ScheduleItems
                .Where(s => s.ManagerId == managerId && s.IsApproved == false)
                .OrderBy(s => s.EventDate)
                .ToListAsync();
        }

        // 3. Onaylı Programları Getir (Flutter Servisindeki approved/id için)
        [HttpGet("approved/{managerId}")]
        public async Task<ActionResult<IEnumerable<ScheduleItem>>> GetApprovedSchedules(int managerId)
        {
            return await _context.ScheduleItems
                .Where(s => s.ManagerId == managerId && s.IsApproved == true)
                .OrderBy(s => s.EventDate)
                .ToListAsync();
        }

        // 4. Programı Onayla veya Revizyon İste
        // api/Schedules/{id}/status
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateStatusDto dto)
        {
            var item = await _context.ScheduleItems.FindAsync(id);
            if (item == null) return NotFound();

            item.IsApproved = dto.IsApproved;
            // Onaylanırsa "Approved", reddedilirse "Revision" durumuna geçer
            item.Status = dto.IsApproved ? "Approved" : "Revision"; 
            item.Feedback = dto.Feedback;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Durum güncellendi." });
        }

        // Data Transfer Object (DTO)
        public class UpdateStatusDto {
            public bool IsApproved { get; set; }
            public string? Feedback { get; set; }
        }
        // 4. Sekreterin Programı Revize Etmesi (Tüm içeriği günceller)
        // PUT api/Schedules/8
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSchedule(int id, [FromBody] ScheduleItem updatedItem)
        {
            // Id kontrolü: URL'deki id ile body içindeki id uyuşmalı (Opsiyonel ama güvenli)
            var item = await _context.ScheduleItems.FindAsync(id);
            if (item == null) return NotFound("Kayıt bulunamadı.");

            // Sadece sekreterin değiştirebildiği alanları güncelle
            item.EventName = updatedItem.EventName;
            item.EventDate = updatedItem.EventDate;
            item.EventTime = updatedItem.EventTime;
            item.Description = updatedItem.Description;
            // Status ve IsApproved değerlerini "onaya tekrar gönderilecek" şekilde sıfırla
            item.Status = "Pending"; 
            item.IsApproved = false;
            item.Feedback = ""; 

            try {
                await _context.SaveChangesAsync();
                return Ok(new { message = "Program başarıyla revize edildi ve onaya gönderildi." });
            } catch (Exception ex) {
                return StatusCode(500, "Veritabanı güncelleme hatası: " + ex.Message);
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ScheduleItem>> GetScheduleById(int id)
        {
            var item = await _context.ScheduleItems.FindAsync(id);
            return item == null ? NotFound() : Ok(item);
        }
    }
}