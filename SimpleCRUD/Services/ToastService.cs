namespace SimpleCRUD.Services;

public class ToastService
{
    public event Action<string, string, string>? OnShow;

    public void ShowSuccess(string message) =>
        OnShow?.Invoke("Success", message, "bg-success text-white");

    public void ShowError(string message) =>
        OnShow?.Invoke("Error", message, "bg-danger text-white");

    public void ShowInfo(string message) =>
        OnShow?.Invoke("Info", message, "bg-info text-white");

    public void ShowWarning(string message) =>
        OnShow?.Invoke("Warning", message, "bg-warning text-dark");
}

