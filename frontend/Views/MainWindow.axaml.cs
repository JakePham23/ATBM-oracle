using Avalonia.Controls;
using Avalonia.Interactivity;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace frontend;

public partial class MainWindow : Window
{
    private static readonly HttpClient http = new HttpClient();

    public MainWindow()
    {
        InitializeComponent();
    }

    private async void OnCreateUserClicked(object? sender, RoutedEventArgs e)
    {
        var payload = new
        {
            username = UsernameBox.Text,
            password = PasswordBox.Text,
            tablespace = string.IsNullOrWhiteSpace(TablespaceBox.Text) ? "USERS" : TablespaceBox.Text,
            profile = string.IsNullOrWhiteSpace(ProfileBox.Text) ? "DEFAULT" : ProfileBox.Text,
            quota = string.IsNullOrWhiteSpace(QuotaBox.Text) ? null : QuotaBox.Text,
            default_role = string.IsNullOrWhiteSpace(RoleBox.Text) ? null : RoleBox.Text,
            grant_sysdba = SysdbaCheckbox.IsChecked ?? false
        };

        var json = JsonSerializer.Serialize(payload);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        try
        {
            var response = await http.PostAsync("http://localhost:4000/api/user/create-user", content);
            var responseText = await response.Content.ReadAsStringAsync();
            ResponseText.Text = response.IsSuccessStatusCode
                ? "✅ User created!"
                : $"❌ Error: {responseText}";
        }
        catch (HttpRequestException ex)
        {
            ResponseText.Text = $"❌ Cannot connect to server: {ex.Message}";
        }
    }
}
