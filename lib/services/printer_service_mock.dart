class PrinterServiceMock {
  Future<bool> printReceipt(String text) async {
    // Simula impressão
    await Future.delayed(const Duration(seconds: 1));
    print('=== IMPRESSÃO SIMULADA ===');
    print(text);
    print('=== FIM DA IMPRESSÃO ===');
    return true;
  }
}
