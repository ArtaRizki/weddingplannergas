<?php

namespace Database\Seeders;

use App\Models\Budget;
use App\Models\Guest;
use App\Models\Phase;
use App\Models\Rundown;
use App\Models\Task;
use App\Models\Vendor;
use App\Models\Wedding;
use Illuminate\Database\Seeder;

class WeddingSeeder extends Seeder
{
    public function run(): void
    {
        $wedding = Wedding::create([
            'groom_name' => 'Budi Santoso',
            'bride_name' => 'Siti Nurhaliza',
            'wedding_date' => '2024-08-15',
            'location' => 'Ballroom Grand Hotel, Jakarta',
            'total_budget' => 500000000,
            'primary_color' => '#FF69B4',
            'secondary_color' => '#FFB6C1',
            'accent_color' => '#FFD700',
        ]);

        // ===== PHASES =====
        $phases = [
            [
                'name' => 'Persiapan Awal',
                'description' => 'Tahap perencanaan dan persiapan awal pernikahan (12-6 bulan sebelum)',
                'order' => 1,
                'start_date' => '2024-01-01',
                'end_date' => '2024-03-01',
                'color' => '#6366F1',
                'icon' => '📋',
            ],
            [
                'name' => 'Vendor & Budget',
                'description' => 'Seleksi vendor, kontrak, dan manajemen budget (6-3 bulan sebelum)',
                'order' => 2,
                'start_date' => '2024-03-01',
                'end_date' => '2024-05-15',
                'color' => '#8B5CF6',
                'icon' => '💼',
            ],
            [
                'name' => 'Undangan & Tamu',
                'description' => 'Kirim undangan dan kelola daftar tamu (3-1 bulan sebelum)',
                'order' => 3,
                'start_date' => '2024-05-15',
                'end_date' => '2024-07-15',
                'color' => '#EC4899',
                'icon' => '💌',
            ],
            [
                'name' => 'Persiapan Akhir',
                'description' => 'Finalisasi semua persiapan (1 bulan - H-1)',
                'order' => 4,
                'start_date' => '2024-07-15',
                'end_date' => '2024-08-14',
                'color' => '#F59E0B',
                'icon' => '⚡',
            ],
            [
                'name' => 'Hari H',
                'description' => 'Eksekusi acara pernikahan',
                'order' => 5,
                'start_date' => '2024-08-15',
                'end_date' => '2024-08-15',
                'color' => '#EF4444',
                'icon' => '💍',
            ],
        ];

        $createdPhases = [];
        foreach ($phases as $phaseData) {
            $createdPhases[] = Phase::create(array_merge($phaseData, ['wedding_id' => $wedding->id]));
        }

        // ===== TASKS per PHASE =====
        $tasksByPhase = [
            // Phase 1: Persiapan Awal
            [
                ['title' => 'Tentukan tanggal pernikahan', 'type' => 'input', 'priority' => 'tinggi', 'due_date' => '2024-01-15', 'completed' => true, 'completed_at' => '2024-01-10', 'description' => 'Diskusikan dengan keluarga kedua belah pihak untuk menentukan tanggal yang tepat', 'category' => 'Persiapan'],
                ['title' => 'Tentukan lokasi pernikahan', 'type' => 'input', 'priority' => 'tinggi', 'due_date' => '2024-01-20', 'completed' => true, 'completed_at' => '2024-01-18', 'description' => 'Pilih venue yang sesuai dengan kapasitas dan budget', 'category' => 'Persiapan'],
                ['title' => 'Tentukan budget awal', 'type' => 'input', 'priority' => 'tinggi', 'due_date' => '2024-01-25', 'completed' => true, 'completed_at' => '2024-01-22', 'description' => 'Tentukan total budget dan alokasi per kategori', 'category' => 'Budget'],
                ['title' => 'Booking venue', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-02-01', 'completed' => true, 'completed_at' => '2024-01-30', 'description' => 'Lakukan booking venue dengan DP minimal 30%', 'category' => 'Vendor'],
                ['title' => 'Survey vendor fotografi', 'type' => 'execution', 'priority' => 'sedang', 'due_date' => '2024-02-15', 'completed' => true, 'completed_at' => '2024-02-12', 'description' => 'Kunjungi minimal 3 vendor fotografi, bandingkan portofolio dan harga', 'category' => 'Vendor'],
                ['title' => 'Survey vendor catering', 'type' => 'execution', 'priority' => 'sedang', 'due_date' => '2024-02-28', 'completed' => true, 'completed_at' => '2024-02-25', 'description' => 'Food tasting dan perbandingan menu dari beberapa vendor', 'category' => 'Vendor'],
            ],
            // Phase 2: Vendor & Budget
            [
                ['title' => 'Input daftar vendor pilihan', 'type' => 'input', 'priority' => 'tinggi', 'due_date' => '2024-03-10', 'completed' => true, 'completed_at' => '2024-03-08', 'description' => 'Masukkan data vendor yang sudah disurvey ke sistem', 'category' => 'Vendor'],
                ['title' => 'Kontrak vendor fotografi', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-03-15', 'completed' => true, 'completed_at' => '2024-03-14', 'description' => 'Tanda tangan kontrak dengan Studio Foto Jaya', 'category' => 'Vendor'],
                ['title' => 'Kontrak vendor catering', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-03-20', 'completed' => true, 'completed_at' => '2024-03-19', 'description' => 'Finalisasi kontrak dan menu dengan Catering Mewah', 'category' => 'Vendor'],
                ['title' => 'DP vendor dekorasi', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-04-01', 'completed' => false, 'description' => 'Bayar DP 50% ke Dekorasi Elegan', 'category' => 'Budget'],
                ['title' => 'Finalisasi menu catering', 'type' => 'input', 'priority' => 'sedang', 'due_date' => '2024-04-15', 'completed' => false, 'description' => 'Pilih menu final: appetizer, main course, dessert', 'category' => 'Vendor'],
                ['title' => 'Kontrak makeup artist', 'type' => 'execution', 'priority' => 'sedang', 'due_date' => '2024-04-20', 'completed' => false, 'description' => 'Booking dan kontrak dengan MUA profesional', 'category' => 'Vendor'],
                ['title' => 'Update realisasi budget', 'type' => 'input', 'priority' => 'sedang', 'due_date' => '2024-05-01', 'completed' => false, 'description' => 'Update semua pembayaran yang sudah dilakukan', 'category' => 'Budget'],
            ],
            // Phase 3: Undangan & Tamu
            [
                ['title' => 'Input daftar tamu lengkap', 'type' => 'input', 'priority' => 'tinggi', 'due_date' => '2024-05-20', 'completed' => false, 'description' => 'Masukkan semua nama tamu dari kedua belah pihak', 'category' => 'Tamu'],
                ['title' => 'Desain undangan', 'type' => 'execution', 'priority' => 'sedang', 'due_date' => '2024-05-25', 'completed' => false, 'description' => 'Koordinasi dengan desainer untuk undangan cetak & digital', 'category' => 'Persiapan'],
                ['title' => 'Cetak undangan', 'type' => 'execution', 'priority' => 'sedang', 'due_date' => '2024-06-01', 'completed' => false, 'description' => 'Cetak undangan fisik di percetakan', 'category' => 'Persiapan'],
                ['title' => 'Kirim undangan', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-06-15', 'completed' => false, 'description' => 'Distribusikan undangan fisik dan digital ke seluruh tamu', 'category' => 'Tamu'],
                ['title' => 'Update konfirmasi RSVP', 'type' => 'input', 'priority' => 'tinggi', 'due_date' => '2024-07-01', 'completed' => false, 'description' => 'Catat konfirmasi kehadiran dari setiap tamu', 'category' => 'Tamu'],
                ['title' => 'Follow-up tamu belum konfirmasi', 'type' => 'execution', 'priority' => 'sedang', 'due_date' => '2024-07-10', 'completed' => false, 'description' => 'Hubungi tamu yang belum merespon undangan', 'category' => 'Tamu'],
            ],
            // Phase 4: Persiapan Akhir
            [
                ['title' => 'Fitting gaun pengantin', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-07-20', 'completed' => false, 'description' => 'Fitting terakhir untuk gaun pengantin wanita dan jas pengantin pria', 'category' => 'Persiapan'],
                ['title' => 'Trial makeup', 'type' => 'execution', 'priority' => 'sedang', 'due_date' => '2024-07-25', 'completed' => false, 'description' => 'Sesi trial makeup dengan MUA yang sudah dikontrak', 'category' => 'Persiapan'],
                ['title' => 'Input rundown acara', 'type' => 'input', 'priority' => 'tinggi', 'due_date' => '2024-08-01', 'completed' => false, 'description' => 'Susun timeline detail acara dari persiapan hingga penutupan', 'category' => 'Persiapan'],
                ['title' => 'Rehearsal pernikahan', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-08-10', 'completed' => false, 'description' => 'Gladi bersih prosesi pernikahan dengan semua pihak terkait', 'category' => 'Persiapan'],
                ['title' => 'Cek venue final', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-08-13', 'completed' => false, 'description' => 'Inspeksi venue terakhir, pastikan layout sesuai rencana', 'category' => 'Vendor'],
                ['title' => 'Pelunasan semua vendor', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-08-14', 'completed' => false, 'description' => 'Bayar sisa pembayaran semua vendor', 'category' => 'Budget'],
            ],
            // Phase 5: Hari H
            [
                ['title' => 'Setup dekorasi venue', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-08-15', 'completed' => false, 'description' => 'Pemasangan dekorasi dan persiapan venue pagi hari', 'category' => 'Persiapan'],
                ['title' => 'Jalankan rundown acara', 'type' => 'execution', 'priority' => 'tinggi', 'due_date' => '2024-08-15', 'completed' => false, 'description' => 'Eksekusi seluruh acara sesuai rundown yang sudah disusun', 'category' => 'Persiapan'],
                ['title' => 'Input absensi tamu hadir', 'type' => 'input', 'priority' => 'sedang', 'due_date' => '2024-08-15', 'completed' => false, 'description' => 'Catat kehadiran tamu yang datang di hari H', 'category' => 'Tamu'],
            ],
        ];

        foreach ($tasksByPhase as $phaseIndex => $tasks) {
            foreach ($tasks as $taskOrder => $taskData) {
                Task::create(array_merge($taskData, [
                    'wedding_id' => $wedding->id,
                    'phase_id' => $createdPhases[$phaseIndex]->id,
                    'order' => $taskOrder + 1,
                ]));
            }
        }

        // ===== BUDGETS =====
        $budgets = [
            ['category' => 'Venue', 'budget' => 100000000, 'actual' => 95000000],
            ['category' => 'Catering', 'budget' => 150000000, 'actual' => 145000000],
            ['category' => 'Fotografi & Videografi', 'budget' => 80000000, 'actual' => 80000000],
            ['category' => 'Dekorasi', 'budget' => 70000000, 'actual' => 65000000],
            ['category' => 'Makeup & Hair', 'budget' => 30000000, 'actual' => 28000000],
            ['category' => 'Undangan', 'budget' => 15000000, 'actual' => 14000000],
            ['category' => 'Honeymoon', 'budget' => 50000000, 'actual' => 0],
        ];

        foreach ($budgets as $b) {
            Budget::create(array_merge($b, ['wedding_id' => $wedding->id]));
        }

        // ===== VENDORS =====
        $vendors = [
            ['name' => 'Studio Foto Jaya', 'category' => 'Fotografi', 'phone' => '081234567890', 'email' => 'info@studiofotojaya.com', 'cost' => 50000000],
            ['name' => 'Catering Mewah', 'category' => 'Catering', 'phone' => '082345678901', 'email' => 'order@cateringmewah.com', 'cost' => 145000000],
            ['name' => 'Dekorasi Elegan', 'category' => 'Dekorasi', 'phone' => '083456789012', 'email' => 'design@dekorasielegan.com', 'cost' => 65000000],
            ['name' => 'Makeup Artist Profesional', 'category' => 'Makeup', 'phone' => '084567890123', 'email' => 'booking@makeupprofi.com', 'cost' => 28000000],
            ['name' => 'Grand Hotel Jakarta', 'category' => 'Venue', 'phone' => '085678901234', 'email' => 'events@grandhotel.com', 'cost' => 95000000],
        ];

        foreach ($vendors as $v) {
            Vendor::create(array_merge($v, ['wedding_id' => $wedding->id]));
        }

        // ===== GUESTS =====
        $guests = [
            ['name' => 'Ayah Budi', 'side' => 'Pria', 'phone' => '081111111111', 'status' => 'Konfirmasi'],
            ['name' => 'Ibu Budi', 'side' => 'Pria', 'phone' => '081111111112', 'status' => 'Konfirmasi'],
            ['name' => 'Ayah Siti', 'side' => 'Wanita', 'phone' => '082222222222', 'status' => 'Konfirmasi'],
            ['name' => 'Ibu Siti', 'side' => 'Wanita', 'phone' => '082222222223', 'status' => 'Konfirmasi'],
            ['name' => 'Kakak Budi', 'side' => 'Pria', 'phone' => '081111111113', 'status' => 'Konfirmasi'],
            ['name' => 'Adik Siti', 'side' => 'Wanita', 'phone' => '082222222224', 'status' => 'Diundang'],
            ['name' => 'Paman Budi', 'side' => 'Pria', 'phone' => '081111111114', 'status' => 'Belum Diundang'],
            ['name' => 'Bibi Siti', 'side' => 'Wanita', 'phone' => '082222222225', 'status' => 'Belum Diundang'],
        ];

        foreach ($guests as $g) {
            Guest::create(array_merge($g, ['wedding_id' => $wedding->id]));
        }

        // ===== RUNDOWNS =====
        $rundowns = [
            ['name' => 'Persiapan Pengantin', 'time' => '06:00', 'location' => 'Hotel - Kamar Pengantin', 'pic' => 'Makeup Artist', 'notes' => 'Makeup dan hair styling untuk pengantin'],
            ['name' => 'Tamu Mulai Berdatangan', 'time' => '08:00', 'location' => 'Ballroom Grand Hotel', 'pic' => 'MC & Usher', 'notes' => 'Sambut tamu dan arahkan ke tempat duduk'],
            ['name' => 'Pembukaan Acara', 'time' => '09:00', 'location' => 'Ballroom Grand Hotel', 'pic' => 'MC', 'notes' => 'Pembukaan dan sambutan dari keluarga'],
            ['name' => 'Prosesi Pengantin', 'time' => '09:30', 'location' => 'Ballroom Grand Hotel', 'pic' => 'Fotografer', 'notes' => 'Pengantin masuk dan duduk di pelaminan'],
            ['name' => 'Ijab Qabul', 'time' => '10:00', 'location' => 'Ballroom Grand Hotel', 'pic' => 'Ustadz', 'notes' => 'Prosesi ijab qabul'],
            ['name' => 'Foto Bersama', 'time' => '10:30', 'location' => 'Ballroom Grand Hotel', 'pic' => 'Fotografer', 'notes' => 'Foto keluarga dan tamu'],
            ['name' => 'Makan Bersama', 'time' => '11:30', 'location' => 'Ballroom Grand Hotel', 'pic' => 'Catering', 'notes' => 'Hidangan makan siang untuk tamu'],
            ['name' => 'Hiburan & Dansa', 'time' => '13:00', 'location' => 'Ballroom Grand Hotel', 'pic' => 'MC & Band', 'notes' => 'Hiburan musik dan dansa pengantin'],
            ['name' => 'Penutupan Acara', 'time' => '15:00', 'location' => 'Ballroom Grand Hotel', 'pic' => 'MC', 'notes' => 'Ucapan terima kasih dan penutupan'],
        ];

        foreach ($rundowns as $r) {
            Rundown::create(array_merge($r, ['wedding_id' => $wedding->id]));
        }
    }
}
