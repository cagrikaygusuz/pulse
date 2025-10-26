import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/domain/entities/pomodoro_session.dart';
import 'package:pulse/presentation/bloc/timer/timer_cubit.dart';
import 'package:pulse/presentation/bloc/timer/timer_state.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TimerCubit, TimerState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer Display
                Expanded(
                  flex: 3,
                  child: _buildTimerDisplay(state),
                ),
                
                // Task Info
                Expanded(
                  flex: 1,
                  child: _buildTaskInfo(state),
                ),
                
                // Controls
                Expanded(
                  flex: 1,
                  child: _buildControls(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerDisplay(TimerState state) {
    String timeText = '25:00';
    Color displayColor = AppColors.primaryAccent;
    
    if (state is TimerRunningState || state is TimerPausedState) {
      final duration = state is TimerRunningState 
          ? state.remainingTime 
          : (state as TimerPausedState).remainingTime;
      
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      
      displayColor = state is TimerRunningState 
          ? AppColors.primaryAccent 
          : AppColors.secondaryAccent;
    } else if (state is TimerCompletedState) {
      timeText = 'Completed!';
      displayColor = AppColors.success;
    } else if (state is TimerSkippedState) {
      timeText = 'Skipped';
      displayColor = AppColors.secondaryAccent;
    }

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: displayColor.withOpacity(0.1),
        border: Border.all(
          color: displayColor,
          width: 8,
        ),
      ),
      child: Center(
        child: Text(
          timeText,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: displayColor,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo(TimerState state) {
    String taskName = 'No task selected';
    String sessionType = '';
    
    if (state is TimerRunningState) {
      taskName = state.taskName;
      sessionType = _getSessionTypeText(state.sessionType);
    } else if (state is TimerPausedState) {
      taskName = state.taskName;
      sessionType = _getSessionTypeText(state.sessionType);
    } else if (state is TimerCompletedState) {
      taskName = state.taskName;
      sessionType = _getSessionTypeText(state.sessionType);
    } else if (state is TimerSkippedState) {
      taskName = state.taskName;
      sessionType = _getSessionTypeText(state.sessionType);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          taskName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          sessionType,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primaryAccent,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, TimerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (state is TimerInitialState) ...[
          ElevatedButton.icon(
            onPressed: () => _startTestTimer(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        
        if (state is TimerRunningState) ...[
          ElevatedButton.icon(
            onPressed: () => context.read<TimerCubit>().pauseTimer(),
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryAccent,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.read<TimerCubit>().skipSession(
              skipReason: SkipReason.userSkipped,
              notes: 'User manually skipped',
            ),
            icon: const Icon(Icons.skip_next),
            label: const Text('Skip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        
        if (state is TimerPausedState) ...[
          ElevatedButton.icon(
            onPressed: () => context.read<TimerCubit>().resumeTimer(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.read<TimerCubit>().skipSession(
              skipReason: SkipReason.userSkipped,
              notes: 'User manually skipped',
            ),
            icon: const Icon(Icons.skip_next),
            label: const Text('Skip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        
        if (state is TimerCompletedState || state is TimerSkippedState) ...[
          ElevatedButton.icon(
            onPressed: () => context.read<TimerCubit>().resetTimer(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        
        if (state is TimerErrorState) ...[
          ElevatedButton.icon(
            onPressed: () => context.read<TimerCubit>().resetTimer(),
            icon: const Icon(Icons.error_outline),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  void _startTestTimer(BuildContext context) {
    context.read<TimerCubit>().startTimer(
      taskId: 'test-task-id',
      taskName: 'Test Task',
      customDuration: const Duration(minutes: 1), // Short duration for testing
    );
  }

  String _getSessionTypeText(SessionType sessionType) {
    switch (sessionType) {
      case SessionType.work:
        return 'Focus Session';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }
}
