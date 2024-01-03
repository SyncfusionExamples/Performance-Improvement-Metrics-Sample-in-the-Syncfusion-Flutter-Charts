# Performance metrics sample in the Syncfusion Flutter Charts

This is a quick-start example to help you check the loading performance of the Syncfusion Flutter Charts package. Here, we have added a persistent callback to the app to check the rendering time of the chart widget. We have also added a custom widget (gesture widget) that handles the tap interaction. When tapping the gesture widget, we call the setState() method to rebuild the widget. In the build method, we start a timer and fetch the current elapsed time in the persistent callback. With every build, the color of the Charts will be changed to visualize that the chart has been completely rendered for the current build. Once the visual changes, tap again the gesture widget to get the chart rendering time.

## Requirements to run the demo
* [VS Code](https://code.visualstudio.com/download)
* [Flutter SDK v2.0.0+](https://flutter.dev/docs/development/tools/sdk/overview)
* [For more development tools](https://flutter.dev/docs/development/tools/devtools/overview)

## How to run this application
To run this application, you need to first clone or download the ‘Performance-Improvement-Metrics-Sample-in-the-Syncfusion-Flutter-Charts’ repository and open it in your preferred IDE. Then, build and run your project to view the output.

## Further help
For more help, check the [Syncfusion Flutter documentation](https://help.syncfusion.com/flutter/introduction/overview), or
 [Flutter documentation](https://flutter.dev/docs/get-started/install).
