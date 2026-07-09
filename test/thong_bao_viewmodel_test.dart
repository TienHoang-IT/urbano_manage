import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/features/thong_bao/ViewModels/thong_bao_viewmodel.dart';
import 'package:urbano_manage/Services/thong_bao_service.dart';
import 'package:urbano_manage/Models/thong_bao_model.dart';

class FakeThongBaoService extends ThongBaoService {
  final List<ThongBao> list;
  final bool shouldFail;

  FakeThongBaoService({required this.list, this.shouldFail = false});

  @override
  Future<List<ThongBao>> fetchThongBaos() async {
    if (shouldFail) throw Exception('Failed to fetch');
    return list;
  }
}

void main() {
  group('ThongBaoViewModel Tests', () {
    final testNotification = ThongBao(
      id: 1,
      tieuDe: 'Announce 1',
      noiDung: 'Content of announce 1',
      nguoiTao: 1,
      tenNguoiTao: 'Admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('fetchThongBaos success updates state', () async {
      final service = FakeThongBaoService(list: [testNotification]);
      final viewModel = ThongBaoViewModel(service: service);

      expect(viewModel.thongBaos, isEmpty);
      await viewModel.fetchThongBaos();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.thongBaos.length, 1);
      expect(viewModel.thongBaos.first.tieuDe, 'Announce 1');
    });

    test('fetchThongBaos failure updates error', () async {
      final service = FakeThongBaoService(list: [], shouldFail: true);
      final viewModel = ThongBaoViewModel(service: service);

      await viewModel.fetchThongBaos();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNotNull);
      expect(viewModel.thongBaos, isEmpty);
    });
  });
}
