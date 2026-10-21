using System.Globalization;
using Microsoft.AspNetCore.Razor.TagHelpers;

namespace ApiJogosMVC.TagHelpers;

[HtmlTargetElement("preco", Attributes = "valor")]
public class PrecoTagHelper : TagHelper
{
    public decimal Valor { get; set; }

    public override void Process(TagHelperContext context, TagHelperOutput output)
    {
        output.TagName = "span";
        output.TagMode = TagMode.StartTagAndEndTag;
        output.Attributes.RemoveAll("valor");
        output.Content.SetContent(Valor.ToString("C2", CultureInfo.GetCultureInfo("pt-BR")));
    }
}
