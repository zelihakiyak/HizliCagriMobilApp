using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HizliCagriAPI.Models
{
    public class ScheduleItem
    {
        public int Id { get; set; }
        public string EventName { get; set; } = string.Empty; 
        public DateTime EventDate { get; set; } 
        public string EventTime { get; set; } = string.Empty; 
        
        public int ManagerId { get; set; } 
        public int SecretaryId { get; set; } 
        
        public bool IsApproved { get; set; } = false; 
        public string Status { get; set; } = "Draft"; 
        public string? Feedback { get; set; } 
        public string Description { get; set; } = string.Empty;
    }
}