using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HizliCagriAPI.Models
{
    public class TaskItem
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Title { get; set; } = string.Empty; // Başlık

        public string Description { get; set; } = string.Empty; // Açıklama

        public string UrgencyLevel { get; set; } = "Orta"; // Düşük, Orta, Yüksek

        public string Status { get; set; } = "Yeni"; // Yeni, Tamamlandı

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // İlişkiler (Foreign Keys)
        
        // Görevi Alan (Sekreter)
        public int AssignedToUserId { get; set; }
        [ForeignKey("AssignedToUserId")]
        public User? AssignedToUser { get; set; }

        // Görevi Veren (Müdür)
        public int AssignedByUserId { get; set; }
        [ForeignKey("AssignedByUserId")]
        public User? AssignedByUser { get; set; }
    }
}