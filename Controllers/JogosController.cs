using ApiJogosMVC.Models;
using ApiJogosMVC.Services;
using Microsoft.AspNetCore.Mvc;

namespace ApiJogosMVC.Controllers;

public class JogosController : Controller
{
    private readonly JogoService _jogos;

    public JogosController(JogoService jogos)
    {
        _jogos = jogos;
    }

    [HttpGet]
    public IActionResult Index(string? nome) => View(_jogos.Listar(nome));

    [HttpGet]
    public IActionResult Create() => View();

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Create([Bind("Nome,Preco,DataLancamento,Genero")] JogoModel jogo)
    {
        if (!ModelState.IsValid)
            return View(jogo);

        _jogos.Cadastrar(jogo);
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public IActionResult Details(int id)
    {
        var jogo = _jogos.BuscarPorId(id);
        return !ModelState.IsValid || jogo is null ? NotFound() : View(jogo);
    }

    [HttpGet]
    public IActionResult Edit(int id)
    {
        var jogo = _jogos.BuscarPorId(id);
        return !ModelState.IsValid || jogo is null ? NotFound() : View(jogo);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Edit([FromRoute] int id, [Bind("Id,Nome,Preco,DataLancamento,Genero")] JogoModel jogo)
    {
        if (id != jogo.Id || _jogos.BuscarPorId(id) is null)
            return NotFound();

        if (!ModelState.IsValid)
            return View(jogo);

        if (!_jogos.Atualizar(id, jogo))
            return NotFound();

        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public IActionResult Delete(int id)
    {
        var jogo = _jogos.BuscarPorId(id);
        return !ModelState.IsValid || jogo is null ? NotFound() : View(jogo);
    }

    [HttpPost]
    [ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public IActionResult DeleteConfirmed([FromRoute] int id)
    {
        if (!ModelState.IsValid || !_jogos.Excluir(id))
            return NotFound();

        return RedirectToAction(nameof(Index));
    }
}
