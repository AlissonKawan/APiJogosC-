using System.Globalization;
using ApiJogosMVC.Services;
using Microsoft.AspNetCore.Localization;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews(options =>
{
    var mensagens = options.ModelBindingMessageProvider;
    mensagens.SetMissingBindRequiredValueAccessor(campo => $"Informe o campo {campo}.");
    mensagens.SetValueMustNotBeNullAccessor(_ => "Informe um valor válido para este campo.");
    mensagens.SetAttemptedValueIsInvalidAccessor((_, campo) => $"Informe um valor válido para {campo}.");
    mensagens.SetValueIsInvalidAccessor(_ => "Informe um valor válido para este campo.");
    mensagens.SetValueMustBeANumberAccessor(campo => $"O campo {campo} deve ser numérico.");
});
builder.Services.AddSingleton<JogoService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
// Campos HTML number enviam ponto decimal; as Views apresentam valores em reais.
app.UseRequestLocalization(new RequestLocalizationOptions
{
    DefaultRequestCulture = new RequestCulture("en-US", "pt-BR"),
    SupportedCultures = [CultureInfo.GetCultureInfo("en-US")],
    SupportedUICultures = [CultureInfo.GetCultureInfo("pt-BR")],
    RequestCultureProviders = []
});
app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Jogos}/{action=Index}/{id?}")
    .WithStaticAssets();


app.Run();
