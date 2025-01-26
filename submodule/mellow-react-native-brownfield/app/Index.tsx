import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  type ViewProps,
  Image,
  TouchableOpacity,
} from "react-native";
import { useNavigation } from "@react-navigation/native";

interface Course {
  source: string;
  title: string;
  chapterText: string;
  onPressAction?: () => void;
}

export type IndexProps = ViewProps & {
  text: string;
};

export default function Index({ text, style, ...otherProps }: IndexProps) {
  const [footerText, setFooterText] = useState({
    chapterText: "Chapter 1",
    titleText: "Sleep 101",
  });

  const navigation = useNavigation();

  const courses: Course[] = [
    {
      source: require("../../../assets/images/learn4.png"),
      title: "Learn 4",
      chapterText: "Chapter 5",
    },
    {
      source: require("../../../assets/images/learn3.png"),
      title: "Learn 3",
      chapterText: "Chapter 4",
    },
    {
      source: require("../../../assets/images/learn2.png"),
      title: "Learn 2",
      chapterText: "Chapter 3",
    },
    {
      source: require("../../../assets/images/learn1.png"),
      title: "Learn 1",
      chapterText: "Chapter 2",
    },
    {
      source: require("../../../assets/images/sleep101.png"),
      title: "Sleep 101",
      chapterText: "Chapter 1",
      onPressAction: async () => {
        navigation.navigate("LearnView", { course: "Kakao" });
      },
    },
  ];

  return (
    <View style={[styles.container, style]} {...otherProps}>
      <View style={styles.content}>
        {courses.map((img, index) => {
          let offset = 0;
          if (index === 0) {
            offset = 47 - 15; // First element
          } else if (index === courses.length - 1) {
            offset = 49 - 15; // Last element
          } else {
            offset = Math.abs(index - Math.floor(courses.length / 2)) * 16;
          }
          return (
            <View
              key={index}
              style={[styles.iconStack, { marginLeft: `${offset}%` }]}
            >
              <TouchableOpacity
                style={[styles.image]}
                activeOpacity={1}
                onPress={img.onPressAction}
              >
                <Image
                  source={img.source}
                  style={styles.image}
                  resizeMode="contain"
                />
              </TouchableOpacity>
            </View>
          );
        })}
      </View>
      <View style={styles.footer}>
        <Text style={styles.chapterText}>{footerText.chapterText}</Text>
        <Text style={styles.titleText}>{footerText.titleText}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#282C34",
  },
  content: {
    flex: 1,
    justifyContent: "center",
    paddingLeft: "15%",
  },
  text: {
    fontFamily: "GothamRoundedMedium",
    paddingTop: 42,
    fontSize: 32,
    lineHeight: 36,
    marginBottom: 8,
    textAlign: "center",
    color: "black",
  },
  image: {
    width: 120,
    height: 120,
  },
  iconStack: {
    marginVertical: 8, // Configurable space between elements
  },
  footer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: "#383D47",
    padding: 16,
  },
  chapterText: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#FFFFFF",
  },
  titleText: {
    fontSize: 16,
    color: "#A0A4AA",
  },
});
