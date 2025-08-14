import 'package:flutter/material.dart';
import 'screen/data_saya.dart';

void main() {
  runApp(const MyApp());
}

/// ====== MODEL ======
class MenuItem {
  final String imagePath;
  final String name;
  final int price; // rupiah (tanpa koma)

  const MenuItem({required this.imagePath, required this.name, required this.price});
}

class CartItem {
  final MenuItem menu;
  int qty;
  CartItem({required this.menu, this.qty = 1});

  int get total => menu.price * qty;
}

/// ====== APP ======
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemesanan Sederhana - Sabda UTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  /// ====== DATA MENU (bisa kamu ganti gambarnya) ======
  final List<MenuItem> menus = const [
    MenuItem(imagePath: 'assets/menu/gambar1.jpg', name: 'Nasi Goreng', price: 15000),
    MenuItem(imagePath: 'assets/menu/gambar2.jpg',  name: 'Mie Goreng',  price: 12000),
    MenuItem(imagePath: 'assets/menu/gambar3.jpg',  name: 'Ayam Bakar',  price: 20000),
    MenuItem(imagePath: 'assets/menu/gambar4.jpg',      name: 'Es Teh',      price: 5000),
  ];

  /// ====== LIST PESANAN ======
  final List<CartItem> cart = [];

  // ---- fungsi utama: tambah/kurang/hapus ----
  void addToCart(MenuItem m) {
    final idx = cart.indexWhere((e) => e.menu.name == m.name);
    setState(() {
      if (idx == -1) {
        cart.add(CartItem(menu: m, qty: 1));
      } else {
        cart[idx].qty += 1;
      }
    });
  }

  void incItem(CartItem c) {
    setState(() => c.qty += 1);
  }

  void decItem(CartItem c) {
    setState(() {
      if (c.qty > 1) {
        c.qty -= 1;
      } else {
        cart.remove(c);
      }
    });
  }

  void removeItem(CartItem c) {
    setState(() => cart.remove(c));
  }

  int get totalQty => cart.fold(0, (sum, e) => sum + e.qty);
  int get totalPrice => cart.fold(0, (sum, e) => sum + e.total);

  String rp(int n) {
    // format sederhana: Rp 12.345
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final revIndex = s.length - i;
      buf.write(s[i]);
      if (revIndex > 1 && revIndex % 3 == 1) buf.write('.');
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MenuView(
        menus: menus,
        onAdd: addToCart,
      ),
      CartView(
        cart: cart,
        onInc: incItem,
        onDec: decItem,
        onRemove: removeItem,
        rp: rp,
        totalQty: totalQty,
        totalPrice: totalPrice,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Pemesanan'),
        actions: [
          // contoh pakai data dari data_saya.dart
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(Datasaya.gambar),
            ),
          )
        ],
      ),
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Pesanan'),
        ],
      ),
    );
  }
}

/// ====== VIEW MENU ======
class MenuView extends StatelessWidget {
  final List<MenuItem> menus;
  final void Function(MenuItem) onAdd;
  const MenuView({super.key, required this.menus, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: menus.length,
      separatorBuilder: (, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = menus[i];
        return Card(
          elevation: 1,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(m.imagePath, width: 56, height: 56, fit: BoxFit.cover),
            ),
            title: Text(m.name),
            subtitle: Text('Harga: ${_HomePageState().rp(m.price)}'), // pakai formatter cepat
            trailing: ElevatedButton.icon(
              onPressed: () => onAdd(m),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            ),
          ),
        );
      },
    );
  }
}

/// ====== VIEW PESANAN ======
class CartView extends StatelessWidget {
  final List<CartItem> cart;
  final void Function(CartItem) onInc;
  final void Function(CartItem) onDec;
  final void Function(CartItem) onRemove;
  final String Function(int) rp;
  final int totalQty;
  final int totalPrice;

  const CartView({
    super.key,
    required this.cart,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
    required this.rp,
    required this.totalQty,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: cart.isEmpty
              ? const Center(child: Text('Keranjang kosong. Tambahkan menu dari tab "Menu".'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.length,
                  separatorBuilder: (, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = cart[i];
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(c.menu.imagePath, width: 56, height: 56, fit: BoxFit.cover),
                        ),
                        title: Text(c.menu.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Harga: ${rp(c.menu.price)}'),
                            Text('Jumlah: ${c.qty}'),
                            Text('Total item: ${rp(c.total)}'), // c * d
                          ],
                        ),
                        trailing: SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(onPressed: () => onDec(c), icon: const Icon(Icons.remove)),
                              Text('${c.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(onPressed: () => onInc(c), icon: const Icon(Icons.add)),
                              IconButton(
                                onPressed: () => onRemove(c),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Total jumlah menu (+= d): $totalQty'),
              Text('Total harga pesanan (+= e): ${rp(totalPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: cart.isEmpty ? null : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pesanan disimpan! (simulasi)')),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Simpan Pesanan'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}