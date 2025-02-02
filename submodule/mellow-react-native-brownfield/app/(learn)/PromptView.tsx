import React from "react";
import { View, Text, StyleSheet, ViewProps, Image } from "react-native";
import Screen from "./model/Screen";

export type PromptViewProps = ViewProps & {
  screen: Screen;
};

export default function PromptView({ screen, ...otherProps }: PromptViewProps) {
  return (
    <View style={styles.container} {...otherProps}>
      {screen.image && (
        <Image
          source={screen.image}
          style={styles.image}
          resizeMode="contain"
        />
      )}
      <Text style={styles.title}>{screen.header}</Text>
      <Text style={styles.text}>{screen.text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: "8%",
  },
  image: {
    height: "60%",
  },
  title: {
    paddingTop: "2%",
    fontFamily: "GothamRnd-Bold",
    fontSize: 18,
    lineHeight: 27,
    color: "white", // Added text color
  },
  text: {
    fontFamily: "GothamRnd-Medium",
    fontSize: 16,
    lineHeight: 24,
    textAlign: "left",
    color: "#BDC1C7", // Added text color
  },
});
