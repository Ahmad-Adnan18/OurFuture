import 'package:flutter/material.dart';
import '../../models/storage_account.dart';
import '../../services/wallet_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final _walletService = WalletService();
  List<StorageAccount> _wallets = [];
  bool _isLoading = true;
  String? _error;

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    print('DEBUG: Starting _loadWallets');
    // Don't access context here synchronously as it might be called from initState
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('DEBUG: Calling _walletService.getWallets()');
      final wallets = await _walletService.getWallets();
      print('DEBUG: _walletService.getWallets() returned: ${wallets.length} wallets');
      
      if (mounted) {
        setState(() {
          _wallets = wallets;
          _isLoading = false;
        });
      }
      print('DEBUG: setState called with success');
    } catch (e, stackTrace) {
      print('DEBUG: Error in _loadWallets: $e');
      print('DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.failedToLoadWallets;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showWalletDialog({StorageAccount? wallet}) async {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = wallet != null;
    final nameController = TextEditingController(text: wallet?.name ?? '');
    final balanceController = TextEditingController(
      text: wallet?.balance.toStringAsFixed(0) ?? '',
    );
    String selectedType = wallet?.type ?? 'bank';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? l10n.editWallet : l10n.newWallet),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.walletName,
                  hintText: l10n.walletNameHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: l10n.type,
                  border: const OutlineInputBorder(),
                ),
                items: [
                   DropdownMenuItem(value: 'bank', child: Text(l10n.walletTypeBank)),
                   DropdownMenuItem(value: 'e-wallet', child: Text(l10n.walletTypeEWallet)),
                   DropdownMenuItem(value: 'investment', child: Text(l10n.walletTypeInvestment)),
                   DropdownMenuItem(value: 'cash', child: Text(l10n.walletTypeCash)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.balance,
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                
                final balance = double.tryParse(
                  balanceController.text.replaceAll(',', ''),
                ) ?? 0;

                try {
                  if (isEditing) {
                    await _walletService.updateWallet(
                      wallet.id,
                      name: nameController.text,
                      type: selectedType,
                      balance: balance,
                    );
                  } else {
                    await _walletService.createWallet(
                      name: nameController.text,
                      type: selectedType,
                      balance: balance,
                    );
                  }
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? l10n.failedToUpdateWallet : l10n.failedToCreateWallet),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? l10n.update : l10n.create),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadWallets();
    }
  }

  Future<void> _deleteWallet(StorageAccount wallet) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteWallet),
        content: Text(l10n.deleteWalletConfirmation(wallet.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _walletService.deleteWallet(wallet.id);
        _loadWallets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.walletDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeleteWallet),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wallets),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showWalletDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadWallets,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWallets,
                  child: _wallets.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 64,
                                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.noWalletsYet,
                                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton.icon(
                                      onPressed: () => _showWalletDialog(),
                                      icon: const Icon(Icons.add),
                                      label: Text(l10n.addWallet),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _wallets.length,
                          itemBuilder: (context, index) {
                            final wallet = _wallets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    wallet.typeIcon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                title: Text(
                                  wallet.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(wallet.typeDisplayName),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _currencyFormat.format(wallet.balance),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () => _showWalletDialog(wallet: wallet),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: colorScheme.error,
                                          ),
                                          onPressed: () => _deleteWallet(wallet),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
