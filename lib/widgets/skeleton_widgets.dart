import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonWidgets {
  // Skeleton for lesson cards with the new design
  static Widget lessonCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discipline name with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Advanced Computer Science and Data Structures',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Time
              Text(
                '10:10 - 11:40',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              // Lecture/Seminar type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lecture',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Lecturer
              Text(
                'Dr. Smith Johnson Alexander',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 6),
              // Cabinet
              Text(
                'Room 3405 (Computer Lab)',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 6),
              // Address
              Text(
                '4th Veshnyakovsky Passage, Building 4',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Multiple lesson card skeletons for list
  static Widget lessonListSkeleton({int count = 3}) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: count,
        itemBuilder: (context, index) => lessonCardSkeleton(),
      ),
    );
  }

  // Skeleton for search results
  static Widget searchResultSkeleton() {
    return ListTile(
      leading: Icon(Icons.group),
      title: Text('Computer Science Group 2023-1'),
      subtitle: Text('Department of Information Technology'),
      trailing: Radio<String>(
        value: 'sample',
        groupValue: null,
        onChanged: null,
      ),
    );
  }

  // Multiple search result skeletons
  static Widget searchResultListSkeleton({int count = 5}) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: List.generate(
          count,
          (index) => Column(
            children: [
              searchResultSkeleton(),
              if (index < count - 1) const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }

  // Skeleton for filter options (checkboxes)
  static Widget filterOptionSkeleton() {
    return CheckboxListTile(
      value: true,
      onChanged: null,
      title: Text('Advanced Mathematics and Statistics'),
      subtitle: Text('Prof. Dr. Anderson'),
    );
  }

  // Multiple filter option skeletons
  static Widget filterOptionListSkeleton({int count = 8}) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: List.generate(count, (index) => filterOptionSkeleton()),
      ),
    );
  }

  // Generic skeleton wrapper for any widget
  static Widget wrap(Widget child, {bool enabled = true}) {
    return Skeletonizer(
      enabled: enabled,
      child: child,
    );
  }
}