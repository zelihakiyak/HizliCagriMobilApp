using HizliCagriAPI.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// CORS politikasını ekle (Tüm kaynaklara izin ver)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", b => b.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // JSON serileştirme sırasında sonsuz döngüleri (User -> Task -> User) engeller
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping;
    });
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// ... Program.cs içindeki ilgili kısım ...

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        // ÖNEMLİ: DbSeeder içindeki metot ismi SeedData ise burayı da öyle yap:
        Console.WriteLine("--> Veritabanı tohumlama işlemi başlıyor...");
        await DbSeeder.SeedAdminUser(services); 
        Console.WriteLine("--> Veritabanı tohumlama işlemi tamamlandı.");
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Veritabanı beslenirken bir hata oluştu.");
        // Hatayı konsola da yazdıralım ki anında görelim:
        Console.WriteLine($"--> KRİTİK HATA: {ex.Message}");
    }
}

app.Run();
