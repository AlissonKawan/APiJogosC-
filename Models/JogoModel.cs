using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace ApiJogosMVC.Models;

public class JogoModel
{
    public int Id { get; set; }

    [Required(ErrorMessage = "Informe o nome do jogo.")]
    [StringLength(120, ErrorMessage = "O nome deve ter no máximo 120 caracteres.")]
    [Display(Name = "Nome do jogo")]
    public string Nome { get; set; } = string.Empty;

    [BindRequired]
    [Required(ErrorMessage = "Informe o preço do jogo.")]
    [Range(typeof(decimal), "0.01", "79228162514264337593543950335", ErrorMessage = "O preço deve ser de pelo menos R$ 0,01.", ParseLimitsInInvariantCulture = true)]
    [Display(Name = "Preço")]
    public decimal Preco { get; set; }

    [BindRequired]
    [Required(ErrorMessage = "Informe a data de lançamento.")]
    [DataType(DataType.Date)]
    [Display(Name = "Data de lançamento")]
    public DateTime DataLancamento { get; set; }

    [BindRequired]
    [Required(ErrorMessage = "Selecione um gênero.")]
    [EnumDataType(typeof(GeneroEnum), ErrorMessage = "Selecione um gênero válido.")]
    [Range(0, 8, ErrorMessage = "Selecione um gênero válido.")]
    [Display(Name = "Gênero")]
    public GeneroEnum Genero { get; set; } = GeneroEnum.NaoSelecionado;
}