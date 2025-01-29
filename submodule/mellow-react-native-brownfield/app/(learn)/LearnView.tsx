import React, { useEffect, useRef, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ViewProps,
  Animated,
  TouchableOpacity,
} from "react-native";
import { sleep101 } from "./model/sleep101";
import Screen from "./model/Screen";
import { useNavigation } from "@react-navigation/native";
import PromptView from "./PromptView";
import IntroView from "./IntroView";
// import NativeLocalStorage from "../../../../specs/NativeLocalStorage";

interface Course {
  screens: Screen[];
}

// Define course assets with their paths
const courseAssets: { [key: string]: Course } = {
  sleep101: sleep101,
  // Add more courses as needed
};

export type LearnViewProps = ViewProps & {
  route: {
    params: {
      course: string;
    };
  };
};

export default function LearnView({ route, ...otherProps }: LearnViewProps) {
  const { course } = route.params;
  const navigation = useNavigation<any>();

  const courseAsset = courseAssets[course];

  const [currentScreenIndex, setCurrentScreenIndex] = useState(0);
  const progressAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // console.log(NativeLocalStorage);
    // const storedValue = NativeLocalStorage?.getItem("myKey");
    // console.log(storedValue);

    Animated.timing(progressAnim, {
      toValue: (currentScreenIndex + 1) / courseAsset.screens.length,
      duration: 500,
      useNativeDriver: false,
    }).start();
  }, [currentScreenIndex]);

  const handleNextScreen = () => {
    if (currentScreenIndex < courseAsset.screens.length - 1) {
      setCurrentScreenIndex(currentScreenIndex + 1);
    } else {
      navigation.popToTop();
    }
  };

  return (
    <View style={styles.containerWrapper}>
      <>
        <View style={styles.progressBarContainer}>
          <Animated.View
            style={[
              styles.progressBar,
              {
                width: progressAnim.interpolate({
                  inputRange: [0, 1],
                  outputRange: ["0%", "100%"],
                }),
              },
            ]}
          />
        </View>
        <TouchableOpacity
          onPress={handleNextScreen}
          style={styles.promptContainer}
        >
          {currentScreenIndex === 0 ? (
            <IntroView
              image={require("../../../../assets/images/sleep101.png")}
              text={courseAsset.screens[currentScreenIndex].header}
            />
          ) : (
            <PromptView screen={courseAsset.screens[currentScreenIndex]} />
          )}
        </TouchableOpacity>
      </>
    </View>
  );
}

const styles = StyleSheet.create({
  containerWrapper: {
    width: "100%",
    height: "100%",
    paddingVertical: "4%",
    paddingHorizontal: "4%",
    backgroundColor: "#222938",
  },
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#141924", // Changed background colo
  },
  promptContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  progressBarContainer: {
    height: 10,
    width: "100%",
    backgroundColor: "#383D47",
    borderRadius: 5,
    overflow: "hidden",
  },
  progressBar: {
    height: "100%",
    backgroundColor: "#37C882",
  },
  courseName: {
    fontFamily: "GothamRnd-Medium",
    fontSize: 24,
    fontWeight: "bold",
  },
  errorText: {
    fontSize: 18,
    color: "red",
  },
});
