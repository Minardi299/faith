import { Spacer, Text, VStack } from '@expo/ui/swift-ui';
import { font, foregroundStyle, padding } from '@expo/ui/swift-ui/modifiers';
import { createWidget, type WidgetEnvironment } from 'expo-widgets';

type DhammapadaWidgetProps = {
  number: number;
  chapterTitle: string;
  text: string;
};

const DhammapadaWidget = (props: DhammapadaWidgetProps, environment: WidgetEnvironment) => {
  'widget';

  const isSmall = environment.widgetFamily === 'systemSmall';

  return (
    <VStack modifiers={[padding({ all: 12 })]}>
      <Text
        modifiers={[
          font({ weight: 'semibold', size: 11 }),
          foregroundStyle('#8a6d3b'),
        ]}
      >
        {`Verse ${props.number} · ${props.chapterTitle}`}
      </Text>
      <Spacer />
      <Text
        modifiers={[
          font({ weight: 'regular', size: isSmall ? 12 : 14 }),
          foregroundStyle('#1c1c1e'),
        ]}
      >
        {props.text}
      </Text>
    </VStack>
  );
};

export default createWidget('DhammapadaWidget', DhammapadaWidget);
