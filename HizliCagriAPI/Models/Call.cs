using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HizliCagriAPI.Models
{
    public class Call
    {
        [Key]
        public int Id { get; set; }

        public DateTime CallTime { get; set; } = DateTime.Now;

        // Çağrıyı Yapan (Müdür)
        public int CallerId { get; set; }
        
        // Çağrıyı Alan (Sekreter)
        public int ReceiverId { get; set; }
        
        public bool IsSeen { get; set; } = false; // Görüldü mü?
    }
}