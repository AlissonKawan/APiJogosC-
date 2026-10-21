using System.ComponentModel.DataAnnotations;

namespace ApiJogosMVC.Models;

public enum GeneroEnum
{
    [Display(Name = "Selecione um gênero")]
    NaoSelecionado = -1,
    [Display(Name = "Ação")]
    Acao = 0,
    Aventura,
    RPG,
    Esporte,
    [Display(Name = "Estratégia")]
    Estrategia,
    [Display(Name = "Simulação")]
    Simulacao,
    Corrida,
    Luta,
    Terror
}