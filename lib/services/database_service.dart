import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/ride.dart';
import '../models/track_point.dart';
import 'package:latlong2/latlong.dart';

class DatabaseService {
  static const _dbName = 'gamma.db';
  static const _dbVersion = 3;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rides (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        name           TEXT    NOT NULL,
        start_time     INTEGER NOT NULL,
        total_distance REAL    NOT NULL,
        avg_speed      REAL    NOT NULL,
        max_speed      REAL    NOT NULL,
        duration_ms    INTEGER NOT NULL,
        moving_time_ms INTEGER NOT NULL,
        elevation_gain REAL    NOT NULL,
        cadence        REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE track_points (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        ride_id        INTEGER NOT NULL,
        lat            REAL    NOT NULL,
        lng            REAL    NOT NULL,
        speed          REAL    NOT NULL,
        altitude       REAL    NOT NULL,
        timestamp      INTEGER NOT NULL,
        segment_break  INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (ride_id) REFERENCES rides(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_track_points_ride_id ON track_points(ride_id)',
    );
    await db.execute(
      'CREATE INDEX idx_rides_start_time ON rides(start_time DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE track_points ADD COLUMN segment_break INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_track_points_ride_id ON track_points(ride_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_rides_start_time ON rides(start_time DESC)',
      );
    }
  }

  // ── Reads ────────────────────────────────────────────────────────────────

  Future<List<Ride>> getAllRides() async {
    final db = await database;
    final rows = await db.query('rides', orderBy: 'start_time DESC');
    return rows.map(Ride.fromMap).toList();
  }

  Future<Ride> getRideWithTrackPoints(int id) async {
    final db = await database;

    final rideRows = await db.query(
      'rides',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rideRows.isEmpty) throw StateError('Ride $id not found');

    final tpRows = await db.query(
      'track_points',
      where: 'ride_id = ?',
      whereArgs: [id],
      orderBy: 'timestamp ASC',
    );

    final trackPoints = tpRows
        .map(
          (r) => TrackPoint(
            position: LatLng(r['lat'] as double, r['lng'] as double),
            speed: (r['speed'] as num).toDouble(),
            altitude: (r['altitude'] as num).toDouble(),
            timestamp:
                DateTime.fromMillisecondsSinceEpoch(r['timestamp'] as int),
            segmentBreak: (r['segment_break'] as int? ?? 0) == 1,
          ),
        )
        .toList();

    return Ride.fromMap(rideRows.first).copyWith(trackPoints: trackPoints);
  }

  // ── Writes ───────────────────────────────────────────────────────────────

  Future<int> insertRide(Ride ride) async {
    final db = await database;
    final id = await db.insert('rides', ride.toMap());

    if (ride.trackPoints.isNotEmpty) {
      final batch = db.batch();
      for (final tp in ride.trackPoints) {
        batch.insert('track_points', {
          'ride_id': id,
          'lat': tp.position.latitude,
          'lng': tp.position.longitude,
          'speed': tp.speed,
          'altitude': tp.altitude,
          'timestamp': tp.timestamp.millisecondsSinceEpoch,
          'segment_break': tp.segmentBreak ? 1 : 0,
        });
      }
      await batch.commit(noResult: true);
    }

    return id;
  }

  Future<void> updateRideName(int id, String name) async {
    final db = await database;
    await db.update(
      'rides',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteRide(int id) async {
    final db = await database;
    await db.delete('rides', where: 'id = ?', whereArgs: [id]);
  }
}

final databaseServiceProvider = Provider<DatabaseService>(
  (_) => DatabaseService(),
);
