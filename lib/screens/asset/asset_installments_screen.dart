import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/asset.dart';
import '../../models/asset_installment.dart';
import '../../providers/asset_installment_provider.dart';

class AssetInstallmentsScreen extends StatefulWidget {
  final Asset asset;

  const AssetInstallmentsScreen({super.key, required this.asset});

  @override
  State<AssetInstallmentsScreen> createState() => _AssetInstallmentsScreenState();
}

class _AssetInstallmentsScreenState extends State<AssetInstallmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AssetInstallmentProvider>(context, listen: false)
            .fetchInstallments(widget.asset.id!));
  }

  void _showEditInstallmentDialog(BuildContext context, AssetInstallment installment) {
    _amountController.text = installment.amount.toString();
    _notesController.text = installment.notes ?? '';
    _dueDate = DateTime.parse(installment.dueDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Angsuran'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Angsuran',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Tanggal Jatuh Tempo'),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_dueDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Show delete confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Angsuran'),
                  content: const Text(
                    'Apakah Anda yakin ingin menghapus angsuran ini?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AssetInstallmentProvider>(
                          context,
                          listen: false,
                        ).deleteInstallment(
                          installment.id!,
                          widget.asset.id!,
                        ).then((_) {
                          Navigator.pop(context); // Close delete dialog
                          Navigator.pop(context); // Close edit dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Angsuran berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        });
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final updatedInstallment = AssetInstallment(
                  id: installment.id,
                  assetId: widget.asset.id!,
                  amount: double.parse(_amountController.text),
                  dueDate: DateFormat('yyyy-MM-dd').format(_dueDate),
                  isPaid: installment.isPaid,
                  paidDate: installment.paidDate,
                  notes: _notesController.text.isEmpty
                      ? null
                      : _notesController.text,
                );

                Provider.of<AssetInstallmentProvider>(context, listen: false)
                    .updateInstallment(installment.id!, updatedInstallment)
                    .then((_) {
                  Navigator.pop(context);
                  _amountController.clear();
                  _notesController.clear();
                  setState(() {
                    _dueDate = DateTime.now();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Angsuran berhasil diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Angsuran'),
      ),
      body: Consumer<AssetInstallmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final installments = provider.installments;
          if (installments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada angsuran',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: installments.length,
            itemBuilder: (context, index) {
              final installment = installments[index];
              final isPastDue = DateTime.parse(installment.dueDate)
                  .isBefore(DateTime.now()) && !installment.isPaid;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    _showEditInstallmentDialog(context, installment);
                  },
                  child: ListTile(
                    title: Text(
                      currencyFormat.format(installment.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(DateTime.parse(installment.dueDate))}',
                        ),
                        if (installment.isPaid && installment.paidDate != null)
                          Text(
                            'Dibayar: ${DateFormat('dd MMM yyyy').format(DateTime.parse(installment.paidDate!))}',
                            style: TextStyle(
                              color: Colors.green[700],
                            ),
                          ),
                        if (installment.notes != null) Text(installment.notes!),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: installment.isPaid
                                ? Colors.green[50]
                                : isPastDue
                                    ? Colors.red[50]
                                    : Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            installment.isPaid
                                ? 'Lunas'
                                : isPastDue
                                    ? 'Terlambat'
                                    : 'Belum Lunas',
                            style: TextStyle(
                              color: installment.isPaid
                                  ? Colors.green[700]
                                  : isPastDue
                                      ? Colors.red[700]
                                      : Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (!installment.isPaid) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () {
                              provider.markAsPaid(installment.id!, widget.asset.id!);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddInstallmentDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Angsuran'),
      ),
    );
  }

  void _showAddInstallmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Angsuran'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Angsuran',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Tanggal Jatuh Tempo'),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_dueDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final installment = AssetInstallment(
                  assetId: widget.asset.id!,
                  amount: double.parse(_amountController.text),
                  dueDate: DateFormat('yyyy-MM-dd').format(_dueDate),
                  notes: _notesController.text.isEmpty
                      ? null
                      : _notesController.text,
                );

                Provider.of<AssetInstallmentProvider>(context, listen: false)
                    .addInstallment(installment)
                    .then((_) {
                  Navigator.pop(context);
                  _amountController.clear();
                  _notesController.clear();
                  setState(() {
                    _dueDate = DateTime.now();
                  });
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 