using HizliCagriAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace HizliCagriAPI.Data
{
    public static class DbSeeder
    {
        public static async Task SeedAdminUser(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            // 1. Departman Kontrolü (İlişkisel yapı için önce departman var olmalı)
            var adminDept = await context.Departments.FirstOrDefaultAsync(d => d.Name == "Yönetim");

            if (adminDept == null)
            {
                adminDept = new Department
                {
                    Name = "Yönetim"
                };
                context.Departments.Add(adminDept);
                await context.SaveChangesAsync(); // ID'nin oluşması için DB'ye yazıyoruz
                Console.WriteLine("--> 'Yönetim' departmanı oluşturuldu.");
            }

            // 2. Admin Kullanıcısı Kontrolü
            bool adminExists = await context.Users.AnyAsync(u => u.Role == "Admin");

            if (!adminExists)
            {
                var defaultAdmin = new User
                {
                    FullName = "Sistem Admini",
                    Email = "admin@sirket.com",
                    Password = "Admin123", 
                    Role = "Admin",
                    IsApproved = true,
                    DepartmentId = adminDept.Id 
                };

                context.Users.Add(defaultAdmin);
                await context.SaveChangesAsync();
                Console.WriteLine("--> Admin hesabı oluşturuldu (admin@sirket.com).");
            }
        }
    }
}